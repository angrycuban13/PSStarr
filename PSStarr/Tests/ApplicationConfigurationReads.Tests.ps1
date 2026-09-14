BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe 'Application configuration section <Section>' -ForEach @(
        @{ Section = 'DownloadClient'; Path = 'config/downloadclient' }
        @{ Section = 'Host'; Path = 'config/host' }
        @{ Section = 'ImportList'; Path = 'config/importlist' }
        @{ Section = 'Indexer'; Path = 'config/indexer' }
        @{ Section = 'MediaManagement'; Path = 'config/mediamanagement' }
        @{ Section = 'Metadata'; Path = 'config/metadata' }
        @{ Section = 'Naming'; Path = 'config/naming' }
        @{ Section = 'Ui'; Path = 'config/ui' }
    ) {
        BeforeEach {
            Mock Invoke-StarrApiRequest {
                [pscustomobject]@{
                    id      = 1
                    enabled = $false
                }
            }
        }

        It 'retrieves the section through a GET request' {
            $result = Get-StarrApplicationConfiguration -InstanceName Main -Section $Section

            $result.id | Should -Be 1
            $result.enabled | Should -BeFalse
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $Path -and $Method -eq 'GET' -and $InstanceName -eq 'Main'
            }
        }

        It 'retrieves the section by configuration ID' {
            Get-StarrApplicationConfiguration -InstanceName Main -Section $Section -ConfigurationId 7

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq "$Path/7" -and $Method -eq 'GET'
            }
        }

        It 'restricts only metadata to Radarr' {
            Get-StarrApplicationConfiguration -InstanceName Main -Section $Section

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                ($Section -eq 'Metadata' -and $ExpectedApplication -eq 'Radarr') -or
                ($Section -ne 'Metadata' -and [string]::IsNullOrEmpty($ExpectedApplication))
            }
        }

    }

    Describe 'Application configuration shared connection contract' {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 1 } }
        }

        It 'forwards explicit credentials' {
            Get-StarrApplicationConfiguration -Url 'http://localhost:7878/base' -ApiKey fixture-key -Section Host

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'config/host' -and $Url -eq 'http://localhost:7878/base' -and $ApiKey -eq 'fixture-key'
            }
        }

        It 'delegates connection inference' {
            Get-StarrApplicationConfiguration -Section Host

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($InstanceName) -and [string]::IsNullOrEmpty($Url)
            }
        }

        It 'rejects invalid IDs and connection values before transport' {
            { Get-StarrApplicationConfiguration -Section Host -ConfigurationId 0 } | Should -Throw
            { Get-StarrApplicationConfiguration -Section Host -ConfigurationId -1 } | Should -Throw
            { Get-StarrApplicationConfiguration -Section Host -InstanceName ' ' } | Should -Throw
            { Get-StarrApplicationConfiguration -Section Host -Url 'ftp://localhost' -ApiKey fixture-key } | Should -Throw
            { Get-StarrApplicationConfiguration -Section Host -Url 'http://localhost' -ApiKey ' ' } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }

    Describe 'Application configuration safety' {
        It 'rejects unknown sections before transport' {
            Mock Invoke-StarrApiRequest {}

            { Get-StarrApplicationConfiguration -Section Unknown } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'redacts all host secret fields without modifying the transport object' {
            $script:hostFixture = [pscustomobject]@{
                id                   = 1
                apiKey               = 'fixture-api-key'
                password             = 'fixture-password'
                passwordConfirmation = 'fixture-confirmation'
                sslCertPassword      = 'fixture-certificate-password'
                proxyPassword        = 'fixture-proxy-password'
                port                 = 7878
                enableSsl            = $false
            }

            Mock Invoke-StarrApiRequest { $script:hostFixture }

            $result = Get-StarrApplicationConfiguration -InstanceName Main -Section Host

            foreach ($field in @('apiKey', 'password', 'passwordConfirmation', 'sslCertPassword', 'proxyPassword')) {
                $result.$field | Should -Be '[REDACTED]'
                $script:hostFixture.$field | Should -Not -Be '[REDACTED]'
            }

            $result.port | Should -Be 7878
            $result.enableSsl | Should -BeFalse
            ($result | ConvertTo-Json) | Should -Not -Match 'fixture-'
        }

        It 'redacts case-insensitive secret names on the ID route' {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ APIKEY = 'fixture-key'; id = 1 } }

            $result = Get-StarrApplicationConfiguration -InstanceName Main -Section host -ConfigurationId 1

            $result.APIKEY | Should -Be '[REDACTED]'
        }

        It 'returns no fabricated object after an empty host response' {
            Mock Invoke-StarrApiRequest {}

            @(Get-StarrApplicationConfiguration -InstanceName Main -Section Host).Count | Should -Be 0
        }
    }
}
