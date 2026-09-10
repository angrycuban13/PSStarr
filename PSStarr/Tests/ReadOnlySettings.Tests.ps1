BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> read-only application settings' -ForEach @(
        @{ Command = 'Get-StarrMetadataProvider'; EndpointPath = 'metadata'; IdParameter = 'MetadataProviderId' }
        @{ Command = 'Get-StarrMetadataProviderSchema'; EndpointPath = 'metadata/schema'; IdParameter = $null }
        @{ Command = 'Get-StarrLanguage'; EndpointPath = 'language'; IdParameter = 'LanguageId' }
        @{ Command = 'Get-StarrDelayProfile'; EndpointPath = 'delayprofile'; IdParameter = 'DelayProfileId' }
        @{ Command = 'Get-StarrCustomFilter'; EndpointPath = 'customfilter'; IdParameter = 'CustomFilterId' }
    ) {
        BeforeEach {
            Mock Invoke-StarrApiRequest {
                [pscustomobject]@{ id = 1 }
                [pscustomobject]@{ id = 2 }
            }
        }

        It 'uses the correct GET endpoint and preserves list results' {
            $result = @(& $Command -Name Main)

            $result.Count | Should -Be 2
            $result[1].id | Should -Be 2
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $EndpointPath -and $Method -eq 'GET' -and $Name -eq 'Main'
            }
        }

        It 'supports explicit connections' {
            & $Command -Url 'http://localhost:8989/base' -ApiKey fixture-key

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $EndpointPath -and $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key'
            }
        }

        It 'delegates inference without specifying a name' {
            & $Command

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($Name) -and [string]::IsNullOrEmpty($Url)
            }
        }

        It 'validates connection parameters before requesting data' {
            { & $Command -Name ' ' } | Should -Throw
            { & $Command -Url 'ftp://localhost' -ApiKey fixture-key } | Should -Throw
            { & $Command -Url 'http://localhost:8989' -ApiKey ' ' } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        if ($IdParameter) {
            It 'uses an individual resource ID' {
                $arguments = @{ Name = 'Main' }
                $arguments[$IdParameter] = 7
                Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 7 } }

                (& $Command @arguments).id | Should -Be 7

                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq "$EndpointPath/7" -and $Method -eq 'GET'
                }
            }

            It 'rejects zero and negative resource IDs' {
                foreach ($id in @(0, -1)) {
                    $arguments = @{ Name = 'Main' }
                    $arguments[$IdParameter] = $id

                    { & $Command @arguments } | Should -Throw
                }

                Should -Invoke Invoke-StarrApiRequest -Times 0
            }
        }
    }
}
