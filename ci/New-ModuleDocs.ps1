[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrWhiteSpace()]
    [System.String]
    $ModulePath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrWhiteSpace()]
    [System.String]
    $OutputPath,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrWhiteSpace()]
    [System.String]
    $RepositoryRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrWhiteSpace()]
    [System.String]
    $DocumentationBaseUri = 'https://psstarr.xyz/modules/PSStarr/',

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrWhiteSpace()]
    [System.String]
    $SourceBaseUri = 'https://github.com/angrycuban13/PSStarr/blob/main/'
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

$requiredPlatyPSVersion = [System.Version]'1.0.3'
$utf8WithoutBom = [System.Text.UTF8Encoding]::new($false)
$failures = [System.Collections.Generic.List[System.String]]::new()
$module = $null
$generationRoot = Join-Path ([System.IO.Path]::GetTempPath()) "PSStarr-docs-$([System.Guid]::NewGuid().ToString('N'))"
$resolvedRepositoryRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
$resolvedModulePath = [System.IO.Path]::GetFullPath($ModulePath)
$resolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
$outputParent = Split-Path $resolvedOutputPath -Parent
$stagingPath = Join-Path $outputParent ".PSStarr-docs-stage-$([System.Guid]::NewGuid().ToString('N'))"
$backupPath = Join-Path $outputParent ".PSStarr-docs-backup-$([System.Guid]::NewGuid().ToString('N'))"

if (-not (Test-Path -LiteralPath $resolvedModulePath -PathType Leaf)) {
    throw "The module manifest does not exist: $resolvedModulePath"
}

if (-not (Test-Path -LiteralPath $resolvedRepositoryRoot -PathType Container)) {
    throw "The repository root does not exist: $resolvedRepositoryRoot"
}

$relativeOutputPath = [System.IO.Path]::GetRelativePath($resolvedRepositoryRoot, $resolvedOutputPath)

if ($relativeOutputPath -eq '..' -or
    $relativeOutputPath.StartsWith("..$([System.IO.Path]::DirectorySeparatorChar)", [System.StringComparison]::Ordinal)) {
    throw 'OutputPath must be inside RepositoryRoot.'
}

$publicSourcePath = Join-Path $resolvedRepositoryRoot 'PSStarr/Source/Public'
$sourceManifestPath = Join-Path $resolvedRepositoryRoot 'PSStarr/Source/PSStarr.psd1'

if (-not (Test-Path -LiteralPath $publicSourcePath -PathType Container)) {
    throw "The public source directory does not exist: $publicSourcePath"
}

$sourceFilesByCommand = @{}

foreach ($sourceFile in @(Get-ChildItem -LiteralPath $publicSourcePath -Recurse -File -Filter '*.ps1')) {
    $commandName = $sourceFile.BaseName

    if ($sourceFilesByCommand.ContainsKey($commandName)) {
        $failures.Add("More than one public source file maps to command '$commandName'.")
        continue
    }

    $sourceFilesByCommand[$commandName] = $sourceFile.FullName
}

$availablePlatyPS = Get-Module -ListAvailable -Name Microsoft.PowerShell.PlatyPS |
    Where-Object Version -EQ $requiredPlatyPSVersion |
    Select-Object -First 1

if ($null -eq $availablePlatyPS) {
    $failures.Add("Microsoft.PowerShell.PlatyPS $requiredPlatyPSVersion is not installed.")
}

if ($failures.Count -eq 0) {
    try {
        $null = Import-Module Microsoft.PowerShell.PlatyPS -RequiredVersion $requiredPlatyPSVersion -Force -PassThru
        $module = Import-Module $resolvedModulePath -Force -PassThru

        if (@($module).Count -ne 1) {
            throw "The manifest imported $(@($module).Count) modules. Expected one module."
        }

        $module = @($module)[0]
        $exportedCommands = @($module.ExportedFunctions.Keys | Sort-Object)

        if ($exportedCommands.Count -eq 0) {
            throw 'The module does not export functions.'
        }

        foreach ($commandName in $exportedCommands) {
            if (-not $sourceFilesByCommand.ContainsKey($commandName)) {
                $failures.Add("No public source file maps to exported command '$commandName'.")
            }
        }

        if ($failures.Count -eq 0) {
            $null = New-Item -ItemType Directory -Path $generationRoot -Force

            $newHelp = @{
                ModuleInfo     = $module
                OutputFolder   = $generationRoot
                WithModulePage = $true
                Force          = $true
                Encoding       = 'utf8NoBOM'
                ErrorAction    = 'Stop'
            }

            # PlatyPS reads optional metadata properties that are absent from some commands.
            $null = & {
                Set-StrictMode -Off
                New-MarkdownCommandHelp @newHelp
            }
        }
    }
    catch {
        $failures.Add("Documentation generation failed: $($_.Exception.Message)")
    }
    finally {
        if ($null -ne $module) {
            Remove-Module -ModuleInfo $module -Force -ErrorAction SilentlyContinue
        }
    }
}

try {
    if ($failures.Count -eq 0) {
        $generatedModulePath = Join-Path $generationRoot 'PSStarr'

        if (-not (Test-Path -LiteralPath $generatedModulePath -PathType Container)) {
            $failures.Add("PlatyPS did not create the expected directory: $generatedModulePath")
        }
        else {
            $null = New-Item -ItemType Directory -Path $stagingPath -Force
            $generatedFiles = @(Get-ChildItem -LiteralPath $generatedModulePath -File -Filter '*.md' | Sort-Object Name)
            $expectedNames = @($exportedCommands | ForEach-Object { "$_.md" }) + 'PSStarr.md'
            $actualNames = @($generatedFiles.Name)
            $nameDifference = @(Compare-Object -ReferenceObject $expectedNames -DifferenceObject $actualNames)

            if ($nameDifference.Count -gt 0) {
                $differenceText = ($nameDifference | ForEach-Object { "$($_.SideIndicator) $($_.InputObject)" }) -join ', '
                $failures.Add("The generated file set does not match the exported commands: $differenceText")
            }

            $duplicateNames = @(
                $actualNames |
                    Group-Object { $_.ToLowerInvariant() } |
                    Where-Object Count -GT 1
            )

            if ($duplicateNames.Count -gt 0) {
                $failures.Add('The generated file set contains case-insensitive duplicate names.')
            }

            foreach ($generatedFile in $generatedFiles) {
                try {
                    $content = [System.IO.File]::ReadAllText($generatedFile.FullName)
                    $content = $content.Replace("`r`n", "`n").Replace("`r", "`n")
                    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?m)[ \t]+$', '')
                    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?m)^ms\.date:.*\n', '')
                    $frontMatter = [System.Text.RegularExpressions.Regex]::Match(
                        $content,
                        '\A---\n.*?^---[ \t]*$',
                        [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::Singleline
                    )

                    if (-not $frontMatter.Success) {
                        throw 'The file does not have valid front matter.'
                    }

                    $content = $content.Insert(
                        $frontMatter.Index + $frontMatter.Length,
                        "`n<!-- markdownlint-disable -->"
                    )

                    $examplesPattern = [System.Text.RegularExpressions.Regex]::new(
                        '(?ms)(^## EXAMPLES[ \t]*\n)(?<Body>.*?)(?=^## |\z)'
                    )
                    $content = $examplesPattern.Replace($content, {
                            param($examplesMatch)

                            $examplePattern = [System.Text.RegularExpressions.Regex]::new(
                                '(?ms)(?<Heading>^### .+?\n)(?<Body>.*?)(?=^### |\z)'
                            )
                            $newBody = $examplePattern.Replace($examplesMatch.Groups['Body'].Value, {
                                    param($exampleMatch)

                                    $body = $exampleMatch.Groups['Body'].Value.Trim()

                                    if ([System.String]::IsNullOrWhiteSpace($body) -or $body.Contains('```')) {
                                        return $exampleMatch.Value
                                    }

                                    $paragraphs = @([System.Text.RegularExpressions.Regex]::Split($body, '\n[ \t]*\n') |
                                            Where-Object { -not [System.String]::IsNullOrWhiteSpace($_) })
                                    $description = $null
                                    $codeParagraphs = $paragraphs

                                    if ($paragraphs.Count -gt 1) {
                                        $description = $paragraphs[-1].Trim()
                                        $codeParagraphs = @($paragraphs[0..($paragraphs.Count - 2)])
                                    }

                                    $code = ($codeParagraphs -join "`n`n").Trim()
                                    $code = [System.Text.RegularExpressions.Regex]::Replace($code, '(?m)^ {4}', '')
                                    $replacement = $exampleMatch.Groups['Heading'].Value.TrimEnd() +
                                    "`n`n" +
                                    '```powershell' +
                                    "`n$code`n" +
                                    '```'

                                    if (-not [System.String]::IsNullOrWhiteSpace($description)) {
                                        $replacement += "`n`n$description"
                                    }

                                    return "$replacement`n`n"
                                })

                            return "$($examplesMatch.Groups[1].Value)$newBody"
                        })

                    $content = [System.Text.RegularExpressions.Regex]::Replace(
                        $content,
                        '(?m)^### \[(.+)\][ \t]*$',
                        '### \[$1\]'
                    )

                    $ioPattern = [System.Text.RegularExpressions.Regex]::new(
                        '(?ms)(?<Heading>^## (?:INPUTS|OUTPUTS)[ \t]*\n)(?<Body>.*?)(?=^## |\z)'
                    )
                    $content = $ioPattern.Replace($content, {
                            param($ioMatch)

                            $body = [System.Text.RegularExpressions.Regex]::Replace(
                                $ioMatch.Groups['Body'].Value,
                                '(?m)^###[ \t]+',
                                ''
                            )
                            $lines = [System.Collections.Generic.List[System.String]]::new()
                            $body.Split("`n") | ForEach-Object { $lines.Add($_) }
                            $firstContentIndex = -1

                            for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
                                if (-not [System.String]::IsNullOrWhiteSpace($lines[$lineIndex])) {
                                    $firstContentIndex = $lineIndex
                                    break
                                }
                            }

                            if ($firstContentIndex -ge 0 -and $lines[$firstContentIndex] -match '^\\?\[(?<Type>.+)\\?\]$') {
                                $typeName = $Matches['Type']
                                $lines[$firstContentIndex] = $typeName

                                for ($lineIndex = $firstContentIndex + 1; $lineIndex -lt $lines.Count; $lineIndex++) {
                                    if ([System.String]::IsNullOrWhiteSpace($lines[$lineIndex])) {
                                        continue
                                    }

                                    if ($lines[$lineIndex].Trim() -eq $typeName) {
                                        $lines.RemoveAt($lineIndex)
                                    }

                                    break
                                }
                            }

                            return "$($ioMatch.Groups['Heading'].Value)$($lines -join "`n")"
                        })

                    $content = [System.Text.RegularExpressions.Regex]::Replace(
                        $content,
                        '(?ms)^## ALIASES[ \t]*\n.*?(?=^## |\z)',
                        ''
                    )
                    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?s)\{\{.*?\}\}', '')
                    $content = $content.Replace('### __AllParameterSets', '### All')

                    $pageName = $generatedFile.BaseName
                    $documentationUri = if ($pageName -eq 'PSStarr') {
                        $DocumentationBaseUri.TrimEnd('/') + '/'
                    }
                    else {
                        $DocumentationBaseUri.TrimEnd('/') + "/$pageName/"
                    }

                    if ($pageName -eq 'PSStarr') {
                        $sourceFilePath = $sourceManifestPath
                    }
                    elseif ($sourceFilesByCommand.ContainsKey($pageName)) {
                        $sourceFilePath = $sourceFilesByCommand[$pageName]
                    }
                    else {
                        throw "No source link is available for '$pageName'."
                    }

                    $relativeSourcePath = [System.IO.Path]::GetRelativePath(
                        $resolvedRepositoryRoot,
                        $sourceFilePath
                    ).Replace([System.IO.Path]::DirectorySeparatorChar, '/')
                    $sourceUri = $SourceBaseUri.TrimEnd('/') + "/$relativeSourcePath"
                    $relatedLinks = "## RELATED LINKS`n`n[$documentationUri]($documentationUri)`n`n[$sourceUri]($sourceUri)`n"
                    $relatedPattern = [System.Text.RegularExpressions.Regex]::new(
                        '(?ms)^## RELATED LINKS[ \t]*\n.*?(?=^## |\z)'
                    )

                    if ($relatedPattern.IsMatch($content)) {
                        $content = $relatedPattern.Replace($content, $relatedLinks, 1)
                    }
                    else {
                        $content = $content.TrimEnd() + "`n`n$relatedLinks"
                    }

                    $content = $content.Replace([System.Char]0x2014, '-')
                    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '\n{3,}', "`n`n")
                    $content = $content.TrimEnd() + "`n"

                    if ($content -match '\{\{.*?\}\}') {
                        throw 'The transformed file contains a PlatyPS placeholder.'
                    }

                    $targetPath = Join-Path $stagingPath $generatedFile.Name
                    [System.IO.File]::WriteAllText($targetPath, $content, $utf8WithoutBom)
                }
                catch {
                    $failures.Add("Failed to transform '$($generatedFile.Name)': $($_.Exception.Message)")
                }
            }
        }
    }

    if ($failures.Count -gt 0) {
        throw "Module documentation generation failed:`n - $($failures -join "`n - ")"
    }

    $stagedFiles = @(Get-ChildItem -LiteralPath $stagingPath -File -Filter '*.md')

    if ($stagedFiles.Count -ne $expectedNames.Count) {
        throw "The staging directory contains $($stagedFiles.Count) files. Expected $($expectedNames.Count)."
    }

    $null = New-Item -ItemType Directory -Path $outputParent -Force

    if (Test-Path -LiteralPath $resolvedOutputPath) {
        Move-Item -LiteralPath $resolvedOutputPath -Destination $backupPath
    }

    try {
        Move-Item -LiteralPath $stagingPath -Destination $resolvedOutputPath
    }
    catch {
        if (Test-Path -LiteralPath $backupPath) {
            Move-Item -LiteralPath $backupPath -Destination $resolvedOutputPath
        }

        throw
    }

    if (Test-Path -LiteralPath $backupPath) {
        Remove-Item -LiteralPath $backupPath -Recurse -Force
    }

    [PSCustomObject]@{
        ModuleName     = 'PSStarr'
        CommandCount   = $exportedCommands.Count
        GeneratedFiles = $stagedFiles.Count
        OutputPath     = $resolvedOutputPath
    }
}
finally {
    if (Test-Path -LiteralPath $generationRoot) {
        Remove-Item -LiteralPath $generationRoot -Recurse -Force
    }

    if (Test-Path -LiteralPath $stagingPath) {
        Remove-Item -LiteralPath $stagingPath -Recurse -Force
    }
}
