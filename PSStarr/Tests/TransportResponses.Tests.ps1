BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Transport response shapes and HTTP failures' {
    InModuleScope PSStarr {
        BeforeEach {
            Mock Write-PSStarrLogEntry
        }

        It 'preserves a paged response and its records' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{
                    page         = 1
                    totalRecords = 2
                    records      = @(
                        [pscustomobject]@{ id = 10 }
                        [pscustomobject]@{ id = 20 }
                    )
                }
            }

            $result = @(Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fixture-key -Endpoint queue)

            $result.Count | Should -Be 1
            $result[0].totalRecords | Should -Be 2
            $result[0].records.Count | Should -Be 2
            $result[0].records[1].id | Should -Be 20
        }

        It 'returns no objects for an empty list' {
            Mock Invoke-RestMethod { Write-Output -NoEnumerate @() }

            @(Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fixture-key -Endpoint health).Count | Should -Be 0
        }

        It 'returns no objects for a null response' {
            Mock Invoke-RestMethod { $null }

            @(Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fixture-key -Endpoint health).Count | Should -Be 0
        }

        It 'sanitizes HTTP <Status> with <Shape> error details' -ForEach @(
            @{ Status = 400; Shape = 'JSON array'; Detail = '[{"errorMessage":"invalid fixture-key"}]' }
            @{ Status = 401; Shape = 'JSON object'; Detail = '{"message":"unauthorized fixture-key"}' }
            @{ Status = 403; Shape = 'plain text'; Detail = 'forbidden fixture-key' }
            @{ Status = 404; Shape = 'empty'; Detail = '' }
            @{ Status = 429; Shape = 'JSON object'; Detail = '{"message":"rate limited fixture-key"}' }
            @{ Status = 500; Shape = 'HTML'; Detail = '<html>failed fixture-key</html>' }
        ) {
            $httpResponse = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode] $Status)
            $exception = [Microsoft.PowerShell.Commands.HttpResponseException]::new("HTTP $Status fixture-key", $httpResponse)
            $failure = [System.Management.Automation.ErrorRecord]::new($exception, 'HttpFailure', 'InvalidOperation', $null)
            $failure.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($Detail)
            Mock Invoke-RestMethod { throw $failure }

            try {
                $caught = $null

                try {
                    Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey fixture-key -Endpoint health -ErrorAction Stop
                }
                catch {
                    $caught = $_
                }

                $caught | Should -Not -BeNullOrEmpty
                $caught.FullyQualifiedErrorId | Should -BeLike 'StarrApiRequestFailed*'
                $caught.Exception.Message | Should -Match "HTTP $Status"
                $caught.Exception.Message | Should -Not -Match 'fixture-key'
                $caught.Exception.Message | Should -Match '\[REDACTED\]'
                Should -Invoke Write-PSStarrLogEntry -Times 1 -Exactly -ParameterFilter {
                    $Message -notmatch 'fixture-key'
                }
            }
            finally {
                $httpResponse.Dispose()
            }
        }
    }
}
