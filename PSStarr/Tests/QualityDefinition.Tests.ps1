BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Quality definition GET wrappers' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 1 } }
        }

        It '<Command> delegates a named GET to <Path>' -ForEach @(
            @{ Command = 'Get-StarrQualityDefinition'; Path = 'qualitydefinition' }
            @{ Command = 'Get-StarrQualityDefinitionLimit'; Path = 'qualitydefinition/limits' }
        ) {
            $expectedPath = $Path
            $result = & $Command -InstanceName Main

            $result.id | Should -Be 1
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $expectedPath -and $InstanceName -eq 'Main' -and $Method -eq 'GET'
            }
        }

        It '<Command> forwards explicit credentials' -ForEach @(
            @{ Command = 'Get-StarrQualityDefinition' }
            @{ Command = 'Get-StarrQualityDefinitionLimit' }
        ) {
            & $Command -Url 'http://localhost:8989/base' -ApiKey 'fixture-key'

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key' -and $Method -eq 'GET'
            }
        }

        It '<Command> leaves instance inference to transport' -ForEach @(
            @{ Command = 'Get-StarrQualityDefinition' }
            @{ Command = 'Get-StarrQualityDefinitionLimit' }
        ) {
            & $Command

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($InstanceName) -and [string]::IsNullOrEmpty($Url)
            }
        }

        It 'uses the individual definition path' {
            Get-StarrQualityDefinition -InstanceName Main -QualityDefinitionId 7

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'qualitydefinition/7' -and $Method -eq 'GET'
            }
        }

        It 'rejects invalid ID <Id> without making a request' -ForEach @(
            @{ Id = 0 }
            @{ Id = -1 }
        ) {
            { Get-StarrQualityDefinition -InstanceName Main -QualityDefinitionId $Id } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'preserves collection output' {
            Mock Invoke-StarrApiRequest {
                [pscustomobject]@{ id = 1 }
                [pscustomobject]@{ id = 2 }
            }

            $result = @(Get-StarrQualityDefinition -InstanceName Main)

            $result.Count | Should -Be 2
            $result[1].id | Should -Be 2
        }

        It 'preserves an empty collection' {
            Mock Invoke-StarrApiRequest {}

            @(Get-StarrQualityDefinition -InstanceName Main).Count | Should -Be 0
        }
    }
}
