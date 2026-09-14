BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Discoverable Prowlarr and tag reads' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ ok = $true } }
        }

        It 'retrieves all configured Prowlarr indexers through API v1' {
            Get-StarrProwlarrIndexer -Name ProwlarrMain

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'ProwlarrMain' -and $Endpoint -eq 'indexer' -and
                $ApiVersion -eq 'v1' -and $ExpectedApplication -eq 'Prowlarr'
            }
        }

        It 'retrieves one configured Prowlarr indexer explicitly' {
            Get-StarrProwlarrIndexer -Url 'http://localhost:9696' -ApiKey fixture -IndexerId 4

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Url -eq 'http://localhost:9696' -and $Endpoint -eq 'indexer/4' -and
                $ApiVersion -eq 'v1' -and $ExpectedApplication -eq 'Prowlarr'
            }
        }

        It 'retrieves tag usage with the descriptive command name' {
            Get-StarrTagUsage -Name Main -TagId 3

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'Main' -and $Endpoint -eq 'tag/detail/3'
            }
        }
    }
}
