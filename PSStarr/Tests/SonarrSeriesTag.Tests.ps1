BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe 'Sonarr bulk series tag changes' {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 42 }; [pscustomobject]@{ id = 43 } }
        }

        It 'adds tags with a narrow body and preserves response objects' {
            $result = @(Set-StarrSonarrSeriesTag -InstanceName Main -SeriesId 42, 43 -TagId 7 -ApplyTags Add -Confirm:$false)

            $result.Count | Should -Be 2
            $result[1].id | Should -Be 43
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'series/editor' -and $Method -eq 'PUT' -and $ApiVersion -eq 'v3' -and
                $ExpectedApplication -eq 'Sonarr' -and $InstanceName -eq 'Main' -and $Body.Count -eq 3 -and
                ($Body.seriesIds -join ',') -eq '42,43' -and $Body.tags.Count -eq 1 -and
                $Body.tags[0] -eq 7 -and $Body.applyTags -eq 'add'
            }
        }

        It 'removes tags using explicit connection settings' {
            Set-StarrSonarrSeriesTag -Url 'http://localhost:8989/base' -ApiKey fixture-key -SeriesId 42 -TagId 7, 8 -ApplyTags Remove -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'series/editor' -and $Method -eq 'PUT' -and $ExpectedApplication -eq 'Sonarr' -and
                $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key' -and
                $Body.seriesIds.Count -eq 1 -and $Body.seriesIds[0] -eq 42 -and
                ($Body.tags -join ',') -eq '7,8' -and $Body.applyTags -eq 'remove' -and $Body.Count -eq 3
            }
        }

        It 'allows inferred connections' {
            Set-StarrSonarrSeriesTag -SeriesId 42 -TagId 7 -ApplyTags Add -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($InstanceName) -and $ExpectedApplication -eq 'Sonarr'
            }
        }

        It 'does not contact the server under WhatIf' {
            Set-StarrSonarrSeriesTag -InstanceName Main -SeriesId 42 -TagId 7 -ApplyTags Remove -WhatIf
            Set-StarrSonarrSeriesTag -Url 'http://localhost:8989' -ApiKey fixture-key -SeriesId 42 -TagId 7 -ApplyTags Add -WhatIf

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'rejects invalid identifiers and replacement before transport' {
            { Set-StarrSonarrSeriesTag -SeriesId 0 -TagId 7 -ApplyTags Add } | Should -Throw
            { Set-StarrSonarrSeriesTag -SeriesId 42 -TagId -1 -ApplyTags Add } | Should -Throw
            { Set-StarrSonarrSeriesTag -SeriesId @() -TagId 7 -ApplyTags Add } | Should -Throw
            { Set-StarrSonarrSeriesTag -SeriesId 42 -TagId @() -ApplyTags Add } | Should -Throw
            { Set-StarrSonarrSeriesTag -SeriesId 42 -TagId 7 -ApplyTags Replace } | Should -Throw
            { Set-StarrSonarrSeriesTag -InstanceName ' ' -SeriesId 42 -TagId 7 -ApplyTags Add } | Should -Throw
            { Set-StarrSonarrSeriesTag -Url 'ftp://localhost' -ApiKey fixture-key -SeriesId 42 -TagId 7 -ApplyTags Add } | Should -Throw
            { Set-StarrSonarrSeriesTag -Url 'http://localhost:8989' -ApiKey ' ' -SeriesId 42 -TagId 7 -ApplyTags Add } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}
