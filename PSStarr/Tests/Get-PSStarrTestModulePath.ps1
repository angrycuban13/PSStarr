<#
.SYNOPSIS
Gets the path of the built PSStarr test manifest.

.DESCRIPTION
This script reads the source manifest version and returns the matching built manifest path.

.EXAMPLE
$manifestPath = & "$PSScriptRoot/Get-PSStarrTestModulePath.ps1"

.INPUTS
None. This script does not accept pipeline input.

.OUTPUTS
System.String. This script returns the full path of the built module manifest.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path $PSScriptRoot -Parent
$sourceManifestPath = Join-Path $projectRoot 'Source/PSStarr.psd1'
$sourceManifest = Import-PowerShellDataFile -Path $sourceManifestPath
$builtManifestPath = Join-Path $projectRoot "Output/PSStarr/$($sourceManifest.ModuleVersion)/PSStarr.psd1"

if (-not (Test-Path -LiteralPath $builtManifestPath -PathType Leaf)) {
    throw "The built PSStarr manifest does not exist at $builtManifestPath."
}

(Resolve-Path -LiteralPath $builtManifestPath).Path
