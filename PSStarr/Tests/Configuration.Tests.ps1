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
            { Set-PSStarrInstance -Name Test -Application Plex -Url 'http://localhost:7878' -ApiKey fake } | Should -Throw
        }

        It 'validates absolute HTTP URLs' {
            { Set-PSStarrInstance -Name Test -Application Radarr -Url 'ftp://localhost/file' -ApiKey fake } | Should -Throw
        }

        It 'persists the name as a key and only three instance fields' -Skip:(-not $IsWindows) {
            Set-PSStarrInstance -Name Main -Application Radarr -Url 'http://localhost:7878/' -ApiKey fake

            Should -Invoke Export-Configuration -Times 1 -ParameterFilter {
                $InputObject.Instances.Count -eq 1 -and
                $InputObject.Instances.Contains('Main') -and
                @($InputObject.Instances.Main.Keys).Count -eq 3 -and
                $InputObject.Instances.Main.Application -eq 'Radarr' -and
                $InputObject.Instances.Main.Url -eq 'http://localhost:7878' -and
                $InputObject.Instances.Main.ApiKey.Mode -eq 'Dpapi' -and
                $InputObject.Instances.Main.ApiKey.CipherText -ne 'fake' -and
                $Scope -eq 'User'
            }
        }

        It 'replaces a instance by key' {
            Mock Import-Configuration {
                @{ Instances = @{ Main = @{ Application = 'Radarr'; Url = 'http://old'; ApiKey = 'old' } } }
            }

            Set-PSStarrInstance -Name Main -Application Radarr -Url 'http://localhost:7878' -ApiKey new -EncryptionMode None

            Should -Invoke Export-Configuration -Times 1 -ParameterFilter {
                $InputObject.Instances.Count -eq 1 -and
                $InputObject.Instances.Main.Url -eq 'http://localhost:7878' -and
                $InputObject.Instances.Main.ApiKey -eq 'new'
            }
        }

        It 'preserves another instance encrypted with an unavailable key' {
            Mock Import-Configuration {
                @{
                    Instances = @{
                        Secondary = @{
                            Application = 'Sonarr'
                            Url         = 'http://localhost:8989'
                            ApiKey      = @{
                                Version    = 1
                                Mode       = 'Aes256'
                                CipherText = 'encrypted'
                            }
                        }
                    }
                }
            }

            Set-PSStarrInstance -Name Main -Application Radarr -Url 'http://localhost:7878' -ApiKey new -EncryptionMode None

            Should -Invoke Export-Configuration -Times 1 -ParameterFilter {
                $InputObject.Instances.Main.ApiKey -eq 'new' -and
                $InputObject.Instances.Secondary.ApiKey.CipherText -eq 'encrypted'
            }
        }

        It 'does not reveal API keys when retrieving a instance' {
            Mock Import-Configuration {
                @{ Instances = @{ Main = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'secret' } } }
            }
            (Get-PSStarrInstance -Name Main).ApiKey | Should -Be '********'
        }

        It 'reports saved encryption modes without decrypting API keys' {
            Mock Import-Configuration {
                @{
                    Instances = @{
                        Encrypted = @{
                            Application = 'Radarr'
                            Url         = 'http://localhost:7878'
                            ApiKey      = @{
                                Version    = 1
                                Mode       = 'Aes256'
                                CipherText = 'encrypted'
                            }
                        }
                        Legacy    = @{
                            Application = 'Sonarr'
                            Url         = 'http://localhost:8989'
                            ApiKey      = 'plaintext'
                        }
                    }
                }
            }
            Mock Unprotect-StarrConfigurationSecret { throw 'Decryption should not occur.' }

            $instances = @(Get-PSStarrInstance)

            ($instances | Where-Object Name -EQ 'Encrypted').EncryptionMode | Should -Be 'Aes256'
            ($instances | Where-Object Name -EQ 'Legacy').EncryptionMode | Should -Be 'None'
            Should -Invoke Unprotect-StarrConfigurationSecret -Times 0
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

            Remove-PSStarrInstance -Name Main -Confirm:$false

            Should -Invoke Export-Configuration -Times 1 -ParameterFilter {
                $InputObject.Instances.Count -eq 1 -and
                $InputObject.Instances.Contains('Secondary') -and
                $Scope -eq 'User'
            }
            Should -Invoke Remove-Item -Times 0
        }

        It 'preserves untouched encrypted API keys when removing an instance' {
            $encryptedApiKey = @{
                Version    = 1
                Mode       = 'Aes256'
                CipherText = 'encrypted'
            }
            Mock Import-Configuration {
                @{
                    Instances = @{
                        Main      = @{
                            Application = 'Radarr'
                            Url         = 'http://localhost:7878'
                            ApiKey      = 'secret'
                        }
                        Secondary = @{
                            Application = 'Sonarr'
                            Url         = 'http://localhost:8989'
                            ApiKey      = $encryptedApiKey
                        }
                    }
                }
            }

            Remove-PSStarrInstance -Name Main -Confirm:$false

            Should -Invoke Export-Configuration -Times 1 -ParameterFilter {
                $InputObject.Instances.Secondary.ApiKey.CipherText -eq 'encrypted' -and
                $InputObject.Instances.Secondary.ApiKey.Mode -eq 'Aes256'
            }
        }

        It 'deletes the final configuration and prunes empty module and author directories' {
            Mock Import-Configuration {
                @{ Instances = @{ Main = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'secret' } } }
            }
            Mock Get-ConfigurationPath { 'C:\Config\AngryCuban13\PSStarr' }
            Mock Test-Path { $true }
            Mock Get-ChildItem { @() }
            Mock Remove-Item

            Remove-PSStarrInstance -Name Main -Confirm:$false

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

            Remove-PSStarrInstance -Name Main -Confirm:$false

            Should -Invoke Remove-Item -Times 1 -ParameterFilter { $LiteralPath -eq 'C:\Config\AngryCuban13\PSStarr' }
            Should -Invoke Remove-Item -Times 0 -ParameterFilter { $LiteralPath -eq 'C:\Config\AngryCuban13' }
        }

        It 'does not change persistence when the instance is missing' {
            Mock Import-Configuration {
                @{ Instances = @{ Other = @{ Application = 'Radarr'; Url = 'http://localhost:7878'; ApiKey = 'secret' } } }
            }
            Mock Remove-Item

            Remove-PSStarrInstance -Name Missing -Confirm:$false -WarningAction SilentlyContinue

            Should -Invoke Export-Configuration -Times 0
            Should -Invoke Remove-Item -Times 0
        }

        It 'honors WhatIf without persistence' {
            $previousKey = [System.Environment]::GetEnvironmentVariable('PSSTARR_AES_KEY')
            [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', $null)

            try {
                Set-PSStarrInstance -Name Main -Application Radarr -Url 'http://localhost:7878' -ApiKey fake -EncryptionMode Aes256 -WhatIf

                Should -Invoke Import-Configuration -Times 0
                Should -Invoke Export-Configuration -Times 0
            }
            finally {
                [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', $previousKey)
            }
        }

        It 'stores plaintext only when explicitly requested' {
            Set-PSStarrInstance -Name Main -Application Radarr -Url 'http://localhost:7878' -ApiKey fake -EncryptionMode None

            Should -Invoke Export-Configuration -Times 1 -ParameterFilter {
                $InputObject.Instances.Main.ApiKey -eq 'fake'
            }
        }

        It 'fails closed when the AES key is unavailable' {
            $previousKey = [System.Environment]::GetEnvironmentVariable('PSSTARR_AES_KEY')
            [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', $null)

            try {
                $errorOutput = @(Set-PSStarrInstance -Name Main -Application Radarr -Url 'http://localhost:7878' -ApiKey secret-key -EncryptionMode Aes256 -ErrorAction Continue 2>&1)

                Should -Invoke Export-Configuration -Times 0
                ($errorOutput | Out-String) | Should -Not -Match 'secret-key'
                $errorOutput[0].FullyQualifiedErrorId | Should -Match '^StarrConfigurationEncryptionFailed'
            }
            finally {
                [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', $previousKey)
            }
        }
    }
}

Describe 'Starr configuration secret protection' {
    InModuleScope PSStarr {
        It 'round trips AES-256 encrypted values with an external key' {
            $previousKey = [System.Environment]::GetEnvironmentVariable('PSSTARR_AES_KEY')
            $key = [System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32)
            [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', [System.Convert]::ToBase64String($key))

            try {
                $protectedValue = Protect-StarrConfigurationSecret -Secret 'secret-value' -EncryptionMode Aes256

                $protectedValue.Version | Should -Be 1
                $protectedValue.Mode | Should -Be 'Aes256'
                $protectedValue.CipherText | Should -Not -Be 'secret-value'
                (Unprotect-StarrConfigurationSecret -Value $protectedValue) | Should -Be 'secret-value'
            }
            finally {
                [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', $previousKey)
            }
        }

        It 'rejects malformed AES-256 keys' {
            $previousKey = [System.Environment]::GetEnvironmentVariable('PSSTARR_AES_KEY')

            try {
                [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', 'not-base64')
                { Get-StarrAesKey } | Should -Throw '*valid Base64*'

                [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', [System.Convert]::ToBase64String([System.Byte[]]::new(16)))
                { Get-StarrAesKey } | Should -Throw '*exactly 32 bytes*'
            }
            finally {
                [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', $previousKey)
            }
        }

        It 'rejects an incorrect AES-256 key without revealing the secret' {
            $previousKey = [System.Environment]::GetEnvironmentVariable('PSSTARR_AES_KEY')
            $firstKey = [System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32)
            $secondKey = [System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32)

            try {
                [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', [System.Convert]::ToBase64String($firstKey))
                $protectedValue = Protect-StarrConfigurationSecret -Secret 'secret-value' -EncryptionMode Aes256
                [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', [System.Convert]::ToBase64String($secondKey))

                $message = try {
                    Unprotect-StarrConfigurationSecret -Value $protectedValue
                }
                catch {
                    $_.Exception.Message
                }

                $message | Should -Match 'Unable to decrypt'
                $message | Should -Not -Match 'secret-value'
            }
            finally {
                [System.Environment]::SetEnvironmentVariable('PSSTARR_AES_KEY', $previousKey)
            }
        }

        It 'round trips DPAPI encrypted values on Windows' -Skip:(-not $IsWindows) {
            $protectedValue = Protect-StarrConfigurationSecret -Secret 'secret-value' -EncryptionMode Dpapi

            $protectedValue.Mode | Should -Be 'Dpapi'
            $protectedValue.CipherText | Should -Not -Be 'secret-value'
            (Unprotect-StarrConfigurationSecret -Value $protectedValue) | Should -Be 'secret-value'
        }

        It 'accepts legacy plaintext values' {
            Unprotect-StarrConfigurationSecret -Value 'legacy-value' | Should -Be 'legacy-value'
        }

        It 'rejects unsupported encrypted envelopes' {
            $value = @{
                Version    = 2
                Mode       = 'Aes256'
                CipherText = 'invalid'
            }

            { Unprotect-StarrConfigurationSecret -Value $value } | Should -Throw '*unsupported encryption version*'
        }

        It 'hydrates encrypted API keys after import' {
            Mock Import-Configuration {
                @{
                    Instances = @{
                        Main = @{
                            Application = 'Radarr'
                            Url         = 'http://localhost:7878'
                            ApiKey      = @{
                                Version    = 1
                                Mode       = 'Dpapi'
                                CipherText = 'encrypted'
                            }
                        }
                    }
                }
            }
            Mock Unprotect-StarrConfigurationSecret { 'decrypted-key' }

            $configuration = Get-StarrConfiguration

            $configuration.Instances.Main.ApiKey | Should -Be 'decrypted-key'
            Should -Invoke Unprotect-StarrConfigurationSecret -Times 1
        }
    }
}
