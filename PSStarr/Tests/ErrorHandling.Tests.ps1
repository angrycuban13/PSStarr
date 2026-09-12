BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Starr error handling and logging' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Invoke-RestMethod { throw 'request failed with key secret-key' }
            Mock Write-PSStarrLogEntry
        }

        It 'throws when ErrorAction is Stop' {
            { Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey secret-key -Endpoint health -ErrorAction Stop } | Should -Throw '*[REDACTED]*'
        }

        It 'emits a nonterminating error when ErrorAction is Continue' {
            $errorOutput = @(Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey secret-key -Endpoint health -ErrorAction Continue 2>&1)
            $errorRecords = @($errorOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })
            $errorRecords.Count | Should -Be 1
            $errorRecords[0].Exception.Message | Should -Not -Match 'secret-key'
        }

        It 'suppresses caller-facing errors when ErrorAction is SilentlyContinue' {
            $errorOutput = @(Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey secret-key -Endpoint health -ErrorAction SilentlyContinue 2>&1)
            $errorOutput.Count | Should -Be 0
        }

        It 'respects an inherited Stop preference' {
            $previousPreference = $ErrorActionPreference
            try {
                $ErrorActionPreference = 'Stop'
                { Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey secret-key -Endpoint health } | Should -Throw
            }
            finally {
                $ErrorActionPreference = $previousPreference
            }
        }

        It 'redacts sensitive values before logging' {
            try { Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey secret-key -Endpoint health -ErrorAction Stop } catch { }
            Should -Invoke Write-PSStarrLogEntry -Times 1 -ParameterFilter {
                $Message -notmatch 'secret-key' -and $Message -match '\[REDACTED\]'
            }
        }


    }
}

Describe 'Write-PSStarrLogEntry' {
    InModuleScope PSStarr {
        It 'writes a plain-text log with an explicit portable path' {
            $logDirectory = Join-Path $TestDrive 'logs'
            Write-PSStarrLogEntry -Message 'portable test' -LogFileDirectory $logDirectory -LogFileName 'PSStarr.log' -NoConsoleOutput
            $logPath = Join-Path $logDirectory 'PSStarr.log'
            Test-Path -LiteralPath $logPath | Should -BeTrue
            Get-Content -Raw -LiteralPath $logPath | Should -Match 'portable test'
        }
    }
}

