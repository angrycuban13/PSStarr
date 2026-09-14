BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> system utility read contract' -ForEach @(
            @{ Command = 'Get-StarrIndexerFlag'; Resource = 'indexerflag'; IsUnversioned = $false }
            @{ Command = 'Get-StarrPing'; Resource = 'ping'; IsUnversioned = $true }
            @{ Command = 'Get-StarrLogEntry'; Resource = 'log'; IsUnversioned = $false }
        ) {
            BeforeEach {
                Mock Invoke-StarrApiRequest { [pscustomobject]@{ ok = $true } }
            }
    
            It 'delegates the correct named GET request' {
                (& $Command -Name Main).ok | Should -BeTrue
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq $Resource -and $Name -eq 'Main' -and
                    $Method -eq 'GET' -and [bool]$Unversioned -eq $IsUnversioned
                }
            }
    
            It 'supports explicit credentials and inference' {
                & $Command -Url 'http://localhost:8989/base' -ApiKey fixture-key
                & $Command
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key'
                }
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    [string]::IsNullOrEmpty($Name) -and [string]::IsNullOrEmpty($Url)
                }
            }
        }
}
