<#
.SYNOPSIS
Prepares the PSStarr manifest and changelog for a release.

.DESCRIPTION
This script sets the module manifest version and converts the current unreleased
changelog section into a dated release section. It does not commit, tag, push, or
publish anything.

.PARAMETER Version
Specifies the stable semantic version to prepare.

.PARAMETER ReleaseDate
Specifies the release date written to the changelog. The default is the current date.

.PARAMETER ManifestPath
Specifies the module manifest to update.

.PARAMETER ChangelogPath
Specifies the changelog to update.

.EXAMPLE
./PSStarr/tools/Prepare-Release.ps1 -Version 1.0.0

.EXAMPLE
./PSStarr/tools/Prepare-Release.ps1 -Version 1.1.0 -ReleaseDate '2026-10-01' -WhatIf

.INPUTS
None. This script does not accept pipeline input.

.OUTPUTS
System.Management.Automation.PSCustomObject. This script returns the prepared version, release date, and updated paths.
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [System.String]
    $Version,

    [Parameter()]
    [System.DateTime]
    $ReleaseDate = [System.DateTime]::Today,

    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [System.String]
    $ManifestPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'Source/PSStarr.psd1'),

    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [System.String]
    $ChangelogPath = (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'CHANGELOG.md')
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

$resolvedManifestPath = (Resolve-Path -LiteralPath $ManifestPath).Path
$resolvedChangelogPath = (Resolve-Path -LiteralPath $ChangelogPath).Path
$manifest = Import-PowerShellDataFile -Path $resolvedManifestPath
$currentVersion = [System.Version]$manifest.ModuleVersion
$targetVersion = [System.Version]$Version

if ($targetVersion -lt $currentVersion) {
    throw "Version $Version cannot be lower than the current module version $currentVersion."
}

$manifestContent = Get-Content -LiteralPath $resolvedManifestPath -Raw
$manifestVersionPattern = "(?m)^(?<Prefix> {4}ModuleVersion\s*=\s*)'[^']+'"
$manifestVersionMatches = [System.Text.RegularExpressions.Regex]::Matches($manifestContent, $manifestVersionPattern)

if ($manifestVersionMatches.Count -ne 1) {
    throw "Expected exactly one ModuleVersion assignment in $resolvedManifestPath."
}

$updatedManifestContent = [System.Text.RegularExpressions.Regex]::Replace(
    $manifestContent,
    $manifestVersionPattern,
    { param($match) "$($match.Groups['Prefix'].Value)'$Version'" }
)

$releaseNotesPattern = "(?m)^(?<Prefix>\s*ReleaseNotes\s*=\s*)'[^']*'"
$releaseNotesMatches = [System.Text.RegularExpressions.Regex]::Matches($updatedManifestContent, $releaseNotesPattern)

if ($releaseNotesMatches.Count -eq 1) {
    $releaseNotes = "PSStarr $Version release. See https://github.com/angrycuban13/PSStarr/blob/main/CHANGELOG.md."
    $updatedManifestContent = [System.Text.RegularExpressions.Regex]::Replace(
        $updatedManifestContent,
        $releaseNotesPattern,
        { param($match) "$($match.Groups['Prefix'].Value)'$releaseNotes'" }
    )
}

$changelogContent = Get-Content -LiteralPath $resolvedChangelogPath -Raw
$escapedVersion = [System.Text.RegularExpressions.Regex]::Escape($Version)
$datedHeadingPattern = "(?m)^## \[$escapedVersion\] - \d{4}-\d{2}-\d{2}\s*$"

if ([System.Text.RegularExpressions.Regex]::IsMatch($changelogContent, $datedHeadingPattern)) {
    throw "CHANGELOG.md already contains a dated $Version release."
}

$versionHeadingPattern = "(?m)^## \[$escapedVersion\] - Unreleased\s*$"
$genericHeadingPattern = '(?m)^## \[Unreleased\]\s*$'
$newHeading = "## [Unreleased]$([System.Environment]::NewLine)$([System.Environment]::NewLine)## [$Version] - $($ReleaseDate.ToString('yyyy-MM-dd'))"

if ([System.Text.RegularExpressions.Regex]::IsMatch($changelogContent, $versionHeadingPattern)) {
    $unreleasedSectionPattern = "(?ms)^## \[$escapedVersion\] - Unreleased\s*(?<Body>.*?)(?=^## \[|\z)"
    $updatedChangelogContent = [System.Text.RegularExpressions.Regex]::Replace(
        $changelogContent,
        $versionHeadingPattern,
        $newHeading,
        1
    )
}
elseif ([System.Text.RegularExpressions.Regex]::IsMatch($changelogContent, $genericHeadingPattern)) {
    $unreleasedSectionPattern = '(?ms)^## \[Unreleased\]\s*(?<Body>.*?)(?=^## \[|\z)'
    $updatedChangelogContent = [System.Text.RegularExpressions.Regex]::Replace(
        $changelogContent,
        $genericHeadingPattern,
        $newHeading,
        1
    )
}
else {
    throw 'CHANGELOG.md does not contain an unreleased section.'
}

$unreleasedSection = [System.Text.RegularExpressions.Regex]::Match($changelogContent, $unreleasedSectionPattern)

if (-not $unreleasedSection.Success -or $unreleasedSection.Groups['Body'].Value -notmatch '(?m)^###\s+') {
    throw 'The unreleased changelog section does not contain any categorized changes.'
}

$targetDescription = "$resolvedManifestPath and $resolvedChangelogPath"

if ($PSCmdlet.ShouldProcess($targetDescription, "Prepare PSStarr $Version release")) {
    Set-Content -LiteralPath $resolvedManifestPath -Value $updatedManifestContent -NoNewline

    Set-Content -LiteralPath $resolvedChangelogPath -Value $updatedChangelogContent -NoNewline

    [pscustomobject]@{
        Version       = $Version
        ReleaseDate   = $ReleaseDate.ToString('yyyy-MM-dd')
        ManifestPath  = $resolvedManifestPath
        ChangelogPath = $resolvedChangelogPath
    }
}
