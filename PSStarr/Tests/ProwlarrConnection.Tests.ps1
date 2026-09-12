BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe 'Prowlarr connections' {
        BeforeEach {
            Mock Write-PSStarrLogEntry
            Mock Invoke-RestMethod { [pscustomobject]@{ appName = 'Prowlarr' } }
            Mock Get-StarrConfiguration {
                @{ Instances = @{ Main = @{ Application = 'Prowlarr'; Url = 'http://localhost:9696/base/'; ApiKey = 'fixture-key' } } }
            }
        }

        It 'selects v1 for a saved Prowlarr connection through a shared wrapper' {
            (Get-StarrSystemStatus -Name Main).appName | Should -Be Prowlarr

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                $Uri -eq 'http://localhost:9696/base/api/v1/system/status' -and $Headers['X-Api-Key'] -eq 'fixture-key'
            }
        }

        It 'infers Prowlarr when it is the only configured connection' {
            Get-StarrHealth

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                $Uri -eq 'http://localhost:9696/base/api/v1/health'
            }
        }

        It 'uses v1 for explicit application-aware requests' {
            Invoke-StarrApiRequest -Url 'http://localhost:9696' -ApiKey fixture-key -ExpectedApplication Prowlarr -Endpoint health

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter { $Uri -eq 'http://localhost:9696/api/v1/health' }
        }

        It 'preserves explicit version overrides' {
            Invoke-StarrApiRequest -Name Main -Endpoint health -ApiVersion v3

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter { $Uri -eq 'http://localhost:9696/base/api/v3/health' }
        }

        It 'masks shared Prowlarr provider credentials' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{ id = 1; fields = @([pscustomobject]@{ name = 'apiKey'; privacy = 'apiKey'; value = 'provider-fixture-secret' }) }
            }

            $result = Get-StarrIndexer -Name Main

            $result.id | Should -Be 1
            $result.fields[0].value | Should -Be '[REDACTED]'
        }

        It 'keeps API info unversioned' {
            Get-StarrApiInfo -Name Main

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter { $Uri -eq 'http://localhost:9696/base/api' }
        }

        It 'rejects Radarr-only commands against Prowlarr' {
            { Get-StarrRadarrMovie -Name Main -ErrorAction Stop } | Should -Throw '*not*Radarr*'
            Should -Invoke Invoke-RestMethod -Times 0
        }

        It 'saves a Prowlarr instance without changing the schema' {
            Mock Import-Configuration { @{ Instances = @{} } }
            Mock Export-Configuration

            Set-PSStarrInstance -Name Main -Application Prowlarr -Url 'http://localhost:9696/' -ApiKey fixture-key -EncryptionMode None

            Should -Invoke Export-Configuration -Times 1 -Exactly -ParameterFilter {
                $InputObject.Instances.Main.Application -eq 'Prowlarr' -and
                $InputObject.Instances.Main.Url -eq 'http://localhost:9696' -and
                @($InputObject.Instances.Main.Keys).Count -eq 3
            }
        }
    }
}
