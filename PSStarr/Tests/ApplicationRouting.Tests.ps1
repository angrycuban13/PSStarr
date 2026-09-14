BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Shared Prowlarr-compatible command routing' {
    BeforeAll {
        $sharedProwlarrCommands = @(
            'Get-StarrBackup'
            'Get-StarrCommand'
            'Get-StarrCustomFilter'
            'Get-StarrDownloadClient'
            'Get-StarrDownloadClientSchema'
            'Get-StarrHealth'
            'Get-StarrIndexer'
            'Get-StarrIndexerSchema'
            'Get-StarrLogEntry'
            'Get-StarrNotification'
            'Get-StarrNotificationSchema'
            'Get-StarrSystemStatus'
            'Get-StarrTag'
            'Get-StarrTagDetail'
            'Get-StarrTagUsage'
            'Get-StarrTask'
            'Get-StarrUpdate'
        )
    }

    It 'passes an explicit Prowlarr application discriminator to the transport' {
        InModuleScope PSStarr -Parameters @{ Commands = $sharedProwlarrCommands } {
            Mock Invoke-StarrApiRequest { @() }

            foreach ($command in $Commands) {
                & $command -Url 'http://localhost:9696' -ApiKey 'test-key' -Application Prowlarr
            }

            Should -Invoke Invoke-StarrApiRequest -Times $Commands.Count -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Prowlarr'
            }
        }
    }

    It 'keeps the application discriminator optional for existing explicit calls' {
        InModuleScope PSStarr -Parameters @{ Commands = $sharedProwlarrCommands } {
            Mock Invoke-StarrApiRequest { @() }

            foreach ($command in $Commands) {
                { & $command -Url 'http://localhost:7878' -ApiKey 'test-key' } | Should -Not -Throw
            }
        }
    }
}

Describe 'Shared Radarr and Sonarr command discrimination' {
    BeforeAll {
        $sharedV3Commands = @(
            'Get-StarrAutoTagging'
            'Get-StarrAutoTaggingSchema'
            'Get-StarrCustomFormat'
            'Get-StarrCustomFormatSchema'
            'Get-StarrDelayProfile'
            'Get-StarrDiskSpace'
            'Get-StarrImportList'
            'Get-StarrImportListSchema'
            'Get-StarrIndexerFlag'
            'Get-StarrLanguage'
            'Get-StarrMetadataProvider'
            'Get-StarrMetadataProviderSchema'
            'Get-StarrQualityDefinition'
            'Get-StarrQualityDefinitionLimit'
            'Get-StarrQualityProfile'
            'Get-StarrQualityProfileSchema'
            'Get-StarrQueueStatus'
            'Get-StarrReleaseProfile'
            'Get-StarrRemotePathMapping'
            'Get-StarrRootFolder'
        )
    }

    It 'passes the explicit application discriminator on every shared v3 read' {
        InModuleScope PSStarr -Parameters @{ Commands = $sharedV3Commands } {
            Mock Invoke-StarrApiRequest { @() }

            foreach ($command in $Commands) {
                & $command -Url 'http://localhost:7878' -ApiKey 'test-key' -Application Radarr
            }

            Should -Invoke Invoke-StarrApiRequest -Times $Commands.Count -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Radarr'
            }
        }
    }

    It 'retains legacy explicit calls without requiring Application' {
        InModuleScope PSStarr -Parameters @{ Commands = $sharedV3Commands } {
            Mock Invoke-StarrApiRequest { @() }

            foreach ($command in $Commands) {
                { & $command -Url 'http://localhost:8989' -ApiKey 'test-key' } | Should -Not -Throw
            }
        }
    }

    It 'limits Application to the two supported v3 applications' {
        InModuleScope PSStarr -Parameters @{ Commands = $sharedV3Commands } {
            foreach ($command in $Commands) {
                { & $command -Url 'http://localhost:9696' -ApiKey 'test-key' -Application Prowlarr } | Should -Throw
            }
        }
    }
}

Describe 'Application discrimination on unversioned and configuration reads' {
    InModuleScope PSStarr {
        It '<Command> forwards a Prowlarr discriminator on an unversioned route' -ForEach @(
            @{ Command = 'Get-StarrApiInfo'; ExpectedEndpoint = 'api' }
            @{ Command = 'Get-StarrPing'; ExpectedEndpoint = 'ping' }
        ) {
            Mock Invoke-StarrApiRequest { @() }

            & $Command -Url 'http://localhost:9696' -ApiKey test-key -Application Prowlarr

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Prowlarr' -and $Unversioned -and $Endpoint -eq $ExpectedEndpoint
            }
        }

        It 'routes supported Prowlarr configuration through API v1 selection' {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 1 } }

            Get-StarrApplicationConfiguration -Url 'http://localhost:9696' -ApiKey test-key -Application Prowlarr -Section Ui

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $ExpectedApplication -eq 'Prowlarr' -and $Endpoint -eq 'config/ui'
            }
        }

        It 'rejects unsupported configuration sections before transport' {
            Mock Invoke-StarrApiRequest { @() }

            { Get-StarrApplicationConfiguration -Name ProwlarrMain -Application Prowlarr -Section Naming } |
                Should -Throw -ErrorId 'StarrConfigurationSectionNotSupported,Get-StarrApplicationConfiguration'
            { Get-StarrApplicationConfiguration -Name SonarrMain -Application Sonarr -Section Metadata } |
                Should -Throw -ErrorId 'StarrConfigurationSectionNotSupported,Get-StarrApplicationConfiguration'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'leaves no generic GET command with explicit credentials but no Application discriminator' {
            $moduleRoot = Split-Path (Get-Module PSStarr).Path -Parent
            $sourceRoot = Resolve-Path (Join-Path $moduleRoot '..\..\..\Source\Public\General') -ErrorAction SilentlyContinue

            if ($sourceRoot) {
                $missing = Get-ChildItem $sourceRoot -Filter 'Get-*.ps1' | Where-Object {
                    $content = Get-Content $_.FullName -Raw
                    $content -match "ParameterSetName = 'Explicit'" -and $content -notmatch '\$Application'
                }

                @($missing).Count | Should -Be 0
            }
        }
    }
}
