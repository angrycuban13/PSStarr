BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'InstanceName parameter contract' {
    InModuleScope PSStarr {
        It 'uses InstanceName as the canonical endpoint parameter and keeps Name as an alias' {
            $parameter = (Get-Command Get-StarrSystemStatus).Parameters.InstanceName

            $parameter | Should -Not -BeNullOrEmpty
            $parameter.Aliases | Should -Contain 'Name'
            (Get-Command Get-StarrSystemStatus).Parameters.ContainsKey('Name') | Should -BeFalse
        }

        It 'keeps Name canonical on PSStarr configuration commands' -ForEach @(
            'Get-PSStarrInstance'
            'Set-PSStarrInstance'
            'Remove-PSStarrInstance'
        ) {
            $parameters = (Get-Command $_).Parameters

            $parameters.ContainsKey('Name') | Should -BeTrue
            $parameters.ContainsKey('InstanceName') | Should -BeFalse
        }

        It 'routes a canonical InstanceName through an endpoint wrapper' {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ appName = 'Starr' } }

            Get-StarrSystemStatus -InstanceName Main

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $InstanceName -eq 'Main' -and $Endpoint -eq 'system/status'
            }
        }

        It 'routes the legacy Name alias through an endpoint wrapper' {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ appName = 'Starr' } }

            Get-StarrSystemStatus -Name Main

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $InstanceName -eq 'Main' -and $Endpoint -eq 'system/status'
            }
        }
    }
}
