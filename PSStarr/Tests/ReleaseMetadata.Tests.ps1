BeforeAll {
    $scriptPath = "$PSScriptRoot/../tools/Test-ReleaseMetadata.ps1"
}

Describe 'Test-ReleaseMetadata' {
    BeforeEach {
        $manifestPath = Join-Path $TestDrive 'PSStarr.psd1'
        $changelogPath = Join-Path $TestDrive 'CHANGELOG.md'

        Set-Content -LiteralPath $manifestPath -Value "@{ ModuleVersion = '1.2.0' }"
        Set-Content -LiteralPath $changelogPath -Value @'
# Changelog

## [Unreleased]

## [1.2.0] - 2026-09-26
### Changed

- Changed release behavior.

## [1.1.0] - 2026-09-01
### Added

- Added prior behavior.
'@
    }

    It 'accepts a newer stable version with categorized release notes' {
        $result = & $scriptPath -ManifestPath $manifestPath -ChangelogPath $changelogPath -PreviousVersion 1.1.0 -PublishedVersion 1.1.0

        $result.Version | Should -Be '1.2.0'
        $result.ReleaseDate | Should -Be '2026-09-26'
    }

    It 'rejects a version with a leading zero' {
        Set-Content -LiteralPath $manifestPath -Value "@{ ModuleVersion = '01.2.0' }"

        { & $scriptPath -ManifestPath $manifestPath -ChangelogPath $changelogPath } | Should -Throw '*stable three-part semantic version*'
    }

    It 'rejects a version equal to the previous version' {
        { & $scriptPath -ManifestPath $manifestPath -ChangelogPath $changelogPath -PreviousVersion 1.2.0 } | Should -Throw '*must be greater than the previous version*'
    }

    It 'rejects a version below the published version' {
        { & $scriptPath -ManifestPath $manifestPath -ChangelogPath $changelogPath -PublishedVersion 1.3.0 } | Should -Throw '*must be greater than the published version*'
    }

    It 'rejects a missing release section' {
        Set-Content -LiteralPath $changelogPath -Value "# Changelog`n`n## [Unreleased]"

        { & $scriptPath -ManifestPath $manifestPath -ChangelogPath $changelogPath } | Should -Throw '*exactly one dated 1.2.0 release*'
    }

    It 'rejects an invalid release date' {
        (Get-Content -LiteralPath $changelogPath -Raw).Replace('2026-09-26', '2026-99-26') |
            Set-Content -LiteralPath $changelogPath

        { & $scriptPath -ManifestPath $manifestPath -ChangelogPath $changelogPath } | Should -Throw '*release date*is not valid*'
    }

    It 'rejects release notes without a category' {
        $content = Get-Content -LiteralPath $changelogPath -Raw
        $content = $content.Replace("### Changed`r`n`r`n", '').Replace("### Changed`n`n", '')
        Set-Content -LiteralPath $changelogPath -Value $content

        { & $scriptPath -ManifestPath $manifestPath -ChangelogPath $changelogPath } | Should -Throw '*categorized release notes*'
    }
}
