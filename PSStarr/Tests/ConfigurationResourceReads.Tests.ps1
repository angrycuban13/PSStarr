BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> configuration-resource read contract' -ForEach @(
            @{ Command = 'Get-StarrMetadataProvider'; EndpointPath = 'metadata'; IdParameter = 'MetadataProviderId' }
            @{ Command = 'Get-StarrMetadataProviderSchema'; EndpointPath = 'metadata/schema'; IdParameter = $null }
            @{ Command = 'Get-StarrLanguage'; EndpointPath = 'language'; IdParameter = 'LanguageId' }
            @{ Command = 'Get-StarrDelayProfile'; EndpointPath = 'delayprofile'; IdParameter = 'DelayProfileId' }
            @{ Command = 'Get-StarrCustomFilter'; EndpointPath = 'customfilter'; IdParameter = 'CustomFilterId' }
            @{ Command = 'Get-StarrReleaseProfile'; EndpointPath = 'releaseprofile'; IdParameter = 'ReleaseProfileId' }
        ) {
            BeforeEach {
                Mock Invoke-StarrApiRequest {
                    [pscustomobject]@{ id = 1 }
                    [pscustomobject]@{ id = 2 }
                }
            }
    
            It 'uses the correct GET endpoint and preserves list results' {
                $result = @(& $Command -InstanceName Main)
    
                $result.Count | Should -Be 2
                $result[1].id | Should -Be 2
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq $EndpointPath -and $Method -eq 'GET' -and $InstanceName -eq 'Main'
                }
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

    Describe 'Configuration-resource connection contract' {
            BeforeEach {
                Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 1 } }
            }
    
            It 'supports explicit connections and inference' {
                Get-StarrLanguage -Url 'http://localhost:8989/base' -ApiKey fixture-key
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key'
                }
    
                Get-StarrLanguage
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    [string]::IsNullOrEmpty($InstanceName) -and [string]::IsNullOrEmpty($Url)
                }
            }
    
            It 'validates connection parameters before requesting data' {
                { Get-StarrLanguage -InstanceName ' ' } | Should -Throw
                { Get-StarrLanguage -Url 'ftp://localhost' -ApiKey fixture-key } | Should -Throw
                { Get-StarrLanguage -Url 'http://localhost:8989' -ApiKey ' ' } | Should -Throw
                Should -Invoke Invoke-StarrApiRequest -Times 0
            }
        }
}
