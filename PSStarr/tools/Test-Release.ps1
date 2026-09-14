[CmdletBinding()]
param()

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path $PSScriptRoot -Parent
$sourcePath = Join-Path $projectRoot 'Source'
$buildPath = Join-Path $projectRoot 'build.psd1'
$outputPath = Join-Path $projectRoot 'Output'
$sourceManifestPath = Join-Path $sourcePath 'PSStarr.psd1'
$sourceManifest = Import-PowerShellDataFile -Path $sourceManifestPath
$moduleVersion = [System.String]$sourceManifest.ModuleVersion
$manifestPath = Join-Path $outputPath "PSStarr/$moduleVersion/PSStarr.psd1"

$analysis = @(
    Invoke-ScriptAnalyzer -Path $sourcePath -Recurse -Severity Warning, Error
    Invoke-ScriptAnalyzer -Path $PSScriptRoot -Recurse -Severity Warning, Error
)

if ($analysis.Count -gt 0) {
    $analysis | Format-Table -AutoSize
    throw "PSScriptAnalyzer returned $($analysis.Count) finding(s)."
}

Build-Module $buildPath

$manifest = Test-ModuleManifest -Path $manifestPath
$null = Import-Module $manifestPath -Force -PassThru

$sourceCommands = @(
    Get-ChildItem (Join-Path $sourcePath 'Public') -Recurse -Filter '*.ps1' |
        ForEach-Object BaseName |
        Sort-Object -Unique
)
$exportedCommands = @(
    (Get-Module PSStarr).ExportedFunctions.Keys |
        Sort-Object -Unique
)
$commandDifference = @(Compare-Object $sourceCommands $exportedCommands)

if ($commandDifference.Count -gt 0) {
    $commandDifference | Format-Table -AutoSize
    throw 'The built module exports do not match the public source files.'
}

foreach ($commandName in $exportedCommands) {
    $help = Get-Help $commandName -Full

    if ([System.String]::IsNullOrWhiteSpace([System.String]$help.Synopsis) -or
        [System.String]::IsNullOrWhiteSpace([System.String]$help.Description.Text)) {
        throw "$commandName does not have complete comment-based help."
    }
}

$pesterResult = Invoke-Pester -Path (Join-Path $projectRoot 'Tests') -Output Normal -PassThru

if ($pesterResult.FailedCount -gt 0 -or $pesterResult.FailedContainersCount -gt 0) {
    throw "Pester failed with $($pesterResult.FailedCount) failed test(s) and $($pesterResult.FailedContainersCount) failed container(s)."
}

$unexpectedPackageFiles = @(
    Get-ChildItem (Split-Path $manifestPath -Parent) -Recurse -File |
        Where-Object Extension -NotIn @('.psd1', '.psm1', '.ps1xml')
)

if ($unexpectedPackageFiles.Count -gt 0) {
    $unexpectedPackageFiles | Select-Object FullName
    throw 'The package contains files outside the approved module artifact set.'
}

[pscustomobject]@{
    ModuleVersion    = $manifest.Version
    ExportedCommands = $exportedCommands.Count
    TestsPassed      = $pesterResult.PassedCount
    TestsSkipped     = $pesterResult.SkippedCount
    PackagePath      = Split-Path $manifestPath -Parent
}
