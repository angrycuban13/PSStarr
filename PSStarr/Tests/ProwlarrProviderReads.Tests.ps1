BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> Prowlarr provider reads' -ForEach @(
        @{ Command = 'Get-StarrProwlarrApplication'; ResourcePath = 'applications'; IdParameter = 'ApplicationId' }
        @{ Command = 'Get-StarrProwlarrApplicationSchema'; ResourcePath = 'applications/schema'; IdParameter = $null }
        @{ Command = 'Get-StarrProwlarrAppProfile'; ResourcePath = 'appprofile'; IdParameter = 'AppProfileId' }
        @{ Command = 'Get-StarrProwlarrAppProfileSchema'; ResourcePath = 'appprofile/schema'; IdParameter = $null }
        @{ Command = 'Get-StarrProwlarrIndexerProxy'; ResourcePath = 'indexerproxy'; IdParameter = 'IndexerProxyId' }
        @{ Command = 'Get-StarrProwlarrIndexerProxySchema'; ResourcePath = 'indexerproxy/schema'; IdParameter = $null }
        @{ Command = 'Get-StarrProwlarrIndexerCategory'; ResourcePath = 'indexer/categories'; IdParameter = $null }
        @{ Command = 'Get-StarrProwlarrIndexerStatus'; ResourcePath = 'indexerstatus'; IdParameter = $null }
    ) {
        BeforeEach {
            Mock Invoke-StarrApiRequest {
                [pscustomobject]@{ id = 1; name = 'Fixture' }
                [pscustomobject]@{ id = 2; name = 'Second' }
            }
        }

        It 'uses Prowlarr v1 GET and preserves list results' {
            $result = @(& $Command -InstanceName Main)

            $result.Count | Should -Be 2
            $result[1].id | Should -Be 2
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $ResourcePath -and $InstanceName -eq 'Main' -and $Method -eq 'GET' -and
                $ApiVersion -eq 'v1' -and $ExpectedApplication -eq 'Prowlarr'
            }
        }

        if ($IdParameter) {
            It 'requests an individual resource by ID' {
                $arguments = @{ Name = 'Main' }
                $arguments[$IdParameter] = 7
                Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 7 } }

                (& $Command @arguments).id | Should -Be 7

                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq "$ResourcePath/7" -and $Method -eq 'GET' -and
                    $ApiVersion -eq 'v1' -and $ExpectedApplication -eq 'Prowlarr'
                }
            }

            It 'rejects invalid IDs' {
                foreach ($id in @(0, -1)) {
                    $arguments = @{ Name = 'Main' }
                    $arguments[$IdParameter] = $id

                    { & $Command @arguments } | Should -Throw
                }

                Should -Invoke Invoke-StarrApiRequest -Times 0
            }
        }
    }

    Describe 'Prowlarr provider shared connection and output contract' {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 1 } }
        }

        It 'supports explicit credentials and v1 routing' {
            Get-StarrProwlarrApplication -Url 'http://localhost:9696/base' -ApiKey fixture-key

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Url -eq 'http://localhost:9696/base' -and $ApiKey -eq 'fixture-key' -and
                $ApiVersion -eq 'v1' -and $ExpectedApplication -eq 'Prowlarr'
            }
        }

        It 'delegates application-filtered inference' {
            Get-StarrProwlarrApplication

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($InstanceName) -and [string]::IsNullOrEmpty($Url) -and
                $ExpectedApplication -eq 'Prowlarr'
            }
        }

        It 'validates credentials before transport' {
            { Get-StarrProwlarrApplication -InstanceName ' ' } | Should -Throw
            { Get-StarrProwlarrApplication -Url 'ftp://localhost' -ApiKey fixture-key } | Should -Throw
            { Get-StarrProwlarrApplication -Url 'http://localhost:9696' -ApiKey ' ' } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'returns no objects for an empty response' {
            Mock Invoke-StarrApiRequest {}

            @(Get-StarrProwlarrApplication -InstanceName Main).Count | Should -Be 0
        }
    }

    Describe '<Command> provider secret protection' -ForEach @(
        @{ Command = 'Get-StarrProwlarrApplication' }
        @{ Command = 'Get-StarrProwlarrApplicationSchema' }
        @{ Command = 'Get-StarrProwlarrIndexerProxy' }
        @{ Command = 'Get-StarrProwlarrIndexerProxySchema' }
    ) {
        It 'redacts private fields and presets without mutating server data' {
            $script:providerFixture = [pscustomobject]@{
                id      = 1
                fields  = @(
                    [pscustomobject]@{ name = 'apiKey'; privacy = 'apiKey'; value = 'fixture-secret' }
                    [pscustomobject]@{ name = 'other'; privacy = 'password'; value = 'fixture-password' }
                    [pscustomobject]@{ name = 'account'; privacy = 'userName'; value = 'fixture-user' }
                    [pscustomobject]@{ name = 'url'; privacy = 'normal'; value = 'http://localhost:7878' }
                )
                presets = @(
                    [pscustomobject]@{
                        fields = @([pscustomobject]@{ name = 'password'; value = 'fixture-preset' })
                    }
                )
            }

            Mock Invoke-StarrApiRequest { $script:providerFixture }

            $result = & $Command -InstanceName Main

            $result.fields.Count | Should -Be 4
            $result.fields[0].value | Should -Be '[REDACTED]'
            $result.fields[1].value | Should -Be '[REDACTED]'
            $result.fields[2].value | Should -Be '[REDACTED]'
            $result.fields[3].value | Should -Be 'http://localhost:7878'
            $result.presets.Count | Should -Be 1
            $result.presets[0].fields.Count | Should -Be 1
            $result.presets[0].fields[0].value | Should -Be '[REDACTED]'
            $script:providerFixture.fields[0].value | Should -Be 'fixture-secret'
            $script:providerFixture.presets[0].fields[0].value | Should -Be 'fixture-preset'
        }
    }

    Describe 'Provider redaction helper shape and safety' {
        It 'supports dictionaries, empty arrays, booleans and null fields' {
            $fixture = @{
                fields  = @(
                    @{ name = 'credential'; type = 'password'; value = 'fixture-value' }
                    @{ name = 'enabled'; privacy = 'normal'; value = $false }
                    @{ name = 'empty'; privacy = 'normal'; value = $null }
                )
                presets = @()
                apiKey  = 'fixture-root-key'
            }

            $result = Protect-StarrProviderResource -Resource $fixture

            $result.fields[0].value | Should -Be '[REDACTED]'
            $result.fields[1].value | Should -BeFalse
            $result.fields[2].value | Should -BeNullOrEmpty
            $result.presets.GetType().FullName | Should -Be 'System.Object[]'
            $result.presets.Count | Should -Be 0
            $result.apiKey | Should -Be '[REDACTED]'
            $fixture.apiKey | Should -Be 'fixture-root-key'
        }

        It 'redacts unknown non-normal privacy and case-insensitive names' {
            $result = Protect-StarrProviderResource -Resource ([pscustomobject]@{
                    fields = @(
                        [pscustomobject]@{ name = 'custom'; privacy = 'futurePrivate'; value = 'fixture-value' }
                        [pscustomobject]@{ name = 'APIKEY'; value = 'fixture-key' }
                    )
                })

            $result.fields[0].value | Should -Be '[REDACTED]'
            $result.fields[1].value | Should -Be '[REDACTED]'
        }

        It 'accepts null resource responses' {
            Protect-StarrProviderResource -Resource $null | Should -BeNullOrEmpty
        }
    }
}
