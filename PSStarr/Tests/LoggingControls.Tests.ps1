BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Process logging controls' {
    InModuleScope PSStarr {
        BeforeEach {
            $previousDisabled = $env:PSSTARR_LOG_DISABLED
            $previousDirectory = $env:PSSTARR_LOG_DIRECTORY
            $env:PSSTARR_LOG_DISABLED = $null
            $env:PSSTARR_LOG_DIRECTORY = $null
            Mock Invoke-RestMethod { throw 'fixture failure' }
            Mock Write-PSStarrLogEntry
        }

        AfterEach {
            $env:PSSTARR_LOG_DISABLED = $previousDisabled
            $env:PSSTARR_LOG_DIRECTORY = $previousDirectory
        }

        It 'disables logging without suppressing the original error' {
            $env:PSSTARR_LOG_DISABLED = '1'

            { Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint health -ErrorAction Stop } | Should -Throw '*fixture failure*'
            Should -Invoke Write-PSStarrLogEntry -Times 0
        }

        It 'uses the requested log directory' {
            $env:PSSTARR_LOG_DIRECTORY = $TestDrive
            $expectedDirectory = $TestDrive

            Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint health -ErrorAction SilentlyContinue

            Should -Invoke Write-PSStarrLogEntry -Times 1 -Exactly -ParameterFilter {
                $LogFileDirectory -eq $expectedDirectory
            }
        }

        It 'keeps logging enabled unless disabled is exactly 1' {
            $env:PSSTARR_LOG_DISABLED = '0'

            Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint health -ErrorAction SilentlyContinue

            Should -Invoke Write-PSStarrLogEntry -Times 1 -Exactly
        }

        It 'uses the default directory when the override is whitespace' {
            $env:PSSTARR_LOG_DIRECTORY = '   '

            Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint health -ErrorAction SilentlyContinue

            Should -Invoke Write-PSStarrLogEntry -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($LogFileDirectory)
            }
        }

        It 'applies changes on the next failure without reimporting the module' {
            $env:PSSTARR_LOG_DISABLED = '1'

            Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint health -ErrorAction SilentlyContinue

            $env:PSSTARR_LOG_DISABLED = $null

            Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint health -ErrorAction SilentlyContinue

            Should -Invoke Write-PSStarrLogEntry -Times 1 -Exactly
        }

        It 'preserves the original failure when logging throws' {
            Mock Write-PSStarrLogEntry { throw 'logger failure' }

            { Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fake -Endpoint health -ErrorAction Stop -WarningAction SilentlyContinue } | Should -Throw '*fixture failure*'
        }
    }
}
