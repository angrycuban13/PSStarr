BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Get-StarrSystemStatus' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ appName = 'Starr' } }
        }

        It 'delegates named requests to the transport' {
            Get-StarrSystemStatus -InstanceName Main

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $InstanceName -eq 'Main' -and $Endpoint -eq 'system/status'
            }
        }

        It 'delegates an explicit <Application> URL to the transport' -ForEach @(
            @{ Application = 'Radarr'; Url = 'http://localhost:7878' }
            @{ Application = 'Sonarr'; Url = 'http://localhost:8989' }
        ) {
            $expectedUrl = $Url

            Get-StarrSystemStatus -Url $expectedUrl -ApiKey fake

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $Url -eq $expectedUrl -and
                $ApiKey -eq 'fake' -and
                $Endpoint -eq 'system/status'
            }
        }

        It 'delegates an inferred request without binding InstanceName' {
            Get-StarrSystemStatus

            Should -Invoke Invoke-StarrApiRequest -Times 1 -ParameterFilter {
                $Endpoint -eq 'system/status' -and
                -not $PSBoundParameters.ContainsKey('InstanceName')
            }
        }
    }
}
