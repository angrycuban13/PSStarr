BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Starr instance configuration' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Import-Configuration { @{ Instances = @{} } }
            Mock Export-Configuration
        }

        It 'validates supported applications' {
            { Set-StarrInstance -Name Test -Application Plex -Url 'http://localhost:7878' -ApiKey fake } | Should -Throw
        }

        It 'validates absolute HTTP URLs' {
            { Set-StarrInstance -Name Test -Application Radarr -Url 'ftp://localhost/file' -ApiKey fake } | Should -Throw
        }

        It 'persists the name as a key and only three instance fields' {
            Set-StarrInstance -Name Main -Application Radarr -Url 'http://localhost:7878/' -ApiKey fake

            Should -Invoke Export-Configuration -Times 1 -ParameterFilter {
                $InputObject.Instances.Count -eq 1 -and
                $InputObject.Instances.Contains('Main') -and
                @($InputObject.Instances.Main.Keys).Count -eq 3 -and
                $InputObject.Instances.Main.Application -eq 'Radarr' -and
                $InputObject.Instances.Main.Url -eq 'http://localhost:7878' -and
                $Scope -eq 'User'
            }
        }

        It 'replaces a instance by key' {
            Mock Import-Configuration {
                @{ Instances = @{ Main = @{ Application = 'Radarr'; Url = 'http://old'; ApiKey = 'old' } } }
            }

            Set-StarrInstance -Name Main -Application Radarr -Url 'http://localhost:7878' -ApiKey new

            Should -Invoke Export-Configuration -Times 1 -ParameterFilter {
                $InputObject.Instances.Count -eq 1 -and
                $InputObject.Instances.Main.Url -eq 'http://localhost:7878' -and
                $InputObject.Instances.Main.ApiKey -eq 'new'
            }
        }


        It 'does not reveal API keys when retrieving a instance' {
            Mock Import-Configuration {
                @{ Instances = @{ Main = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'secret' } } }
            }
            (Get-StarrInstance -Name Main).ApiKey | Should -Be '********'
        }

        It 'exports the reduced configuration when instances remain' {
            Mock Import-Configuration {
                @{ Instances = @{
                        Main      = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'secret' }
                        Secondary = @{ Application = 'Sonarr'; Url = 'http://localhost:8989'; ApiKey = 'secret' }
                    } 
                }
            }
            Mock Remove-Item

            Remove-StarrInstance -Name Main -Confirm:$false

            Should -Invoke Export-Configuration -Times 1 -ParameterFilter {
                $InputObject.Instances.Count -eq 1 -and
                $InputObject.Instances.Contains('Secondary') -and
                $Scope -eq 'User'
            }
            Should -Invoke Remove-Item -Times 0
        }

        It 'deletes the final configuration and prunes empty module and author directories' {
            Mock Import-Configuration {
                @{ Instances = @{ Main = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'secret' } } }
            }
            Mock Get-ConfigurationPath { 'C:\Config\AngryCuban13\PSStarr' }
            Mock Test-Path { $true }
            Mock Get-ChildItem { @() }
            Mock Remove-Item

            Remove-StarrInstance -Name Main -Confirm:$false

            Should -Invoke Export-Configuration -Times 0
            Should -Invoke Get-ConfigurationPath -Times 1 -ParameterFilter { $Scope -eq 'User' -and $SkipCreatingFolder }
            Should -Invoke Remove-Item -Times 1 -ParameterFilter { $LiteralPath -eq 'C:\Config\AngryCuban13\PSStarr\Configuration.psd1' }
            Should -Invoke Remove-Item -Times 1 -ParameterFilter { $LiteralPath -eq 'C:\Config\AngryCuban13\PSStarr' }
            Should -Invoke Remove-Item -Times 1 -ParameterFilter { $LiteralPath -eq 'C:\Config\AngryCuban13' }
        }

        It 'preserves a nonempty author directory' {
            Mock Import-Configuration {
                @{ Instances = @{ Main = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'secret' } } }
            }
            Mock Get-ConfigurationPath { 'C:\Config\AngryCuban13\PSStarr' }
            Mock Test-Path { $true }
            Mock Get-ChildItem { @() } -ParameterFilter { $LiteralPath -eq 'C:\Config\AngryCuban13\PSStarr' }
            Mock Get-ChildItem { @([pscustomobject]@{ Name = 'OtherModule' }) } -ParameterFilter { $LiteralPath -eq 'C:\Config\AngryCuban13' }
            Mock Remove-Item

            Remove-StarrInstance -Name Main -Confirm:$false

            Should -Invoke Remove-Item -Times 1 -ParameterFilter { $LiteralPath -eq 'C:\Config\AngryCuban13\PSStarr' }
            Should -Invoke Remove-Item -Times 0 -ParameterFilter { $LiteralPath -eq 'C:\Config\AngryCuban13' }
        }

        It 'does not change persistence when the instance is missing' {
            Mock Import-Configuration {
                @{ Instances = @{ Other = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'secret' } } }
            }
            Mock Remove-Item

            Remove-StarrInstance -Name Missing -Confirm:$false -WarningAction SilentlyContinue

            Should -Invoke Export-Configuration -Times 0
            Should -Invoke Remove-Item -Times 0
        }

        It 'honors WhatIf without persistence' {
            Set-StarrInstance -Name Main -Application Radarr -Url 'http://localhost:7878' -ApiKey fake -WhatIf
            Should -Invoke Export-Configuration -Times 0
        }
    }
}



