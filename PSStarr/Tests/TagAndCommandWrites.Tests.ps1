BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> tag and generic-command writes' -ForEach @(
            @{ Command = 'New-StarrTag'; ValueParameter = 'Label'; Value = 'reviewed'; ResourcePath = 'tag'; BodyProperty = 'label' }
            @{ Command = 'Start-StarrCommand'; ValueParameter = 'CommandName'; Value = 'RefreshMovie'; ResourcePath = 'command'; BodyProperty = 'name' }
        ) {
            BeforeEach {
                Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 42 } }
                Mock Get-StarrConfiguration { throw 'Unexpected configuration read.' }
            }
    
            It 'sends the named POST request and preserves the result' {
                $arguments = @{ Name = 'Main'; Confirm = $false }
                $arguments[$ValueParameter] = $Value
    
                (& $Command @arguments).id | Should -Be 42
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq $ResourcePath -and $Method -eq 'POST' -and $ApiVersion -eq 'v3' -and
                    $InstanceName -eq 'Main' -and $Body -is [System.Collections.Hashtable] -and
                    $Body.Count -eq 1 -and $Body[$BodyProperty] -eq $Value
                }
            }
    
            It 'supports explicit credentials' {
                $arguments = @{ Url = 'http://localhost:8989/base'; ApiKey = 'fixture-key'; Confirm = $false }
                $arguments[$ValueParameter] = $Value
    
                & $Command @arguments
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key' -and
                    $Endpoint -eq $ResourcePath -and $Method -eq 'POST' -and $ApiVersion -eq 'v3'
                }
            }
    
            It 'delegates connection inference' {
                $arguments = @{ Confirm = $false }
                $arguments[$ValueParameter] = $Value
    
                & $Command @arguments
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    [string]::IsNullOrEmpty($InstanceName) -and [string]::IsNullOrEmpty($Url)
                }
            }
    
            It 'does not invoke transport or read configuration under WhatIf' {
                $arguments = @{ WhatIf = $true }
                $arguments[$ValueParameter] = $Value
    
                @(& $Command @arguments).Count | Should -Be 0
    
                Should -Invoke Invoke-StarrApiRequest -Times 0
                Should -Invoke Get-StarrConfiguration -Times 0
            }
    
            It 'validates the body value and connections before transport' {
                $arguments = @{ Name = 'Main' }
                $arguments[$ValueParameter] = ' '
    
                { & $Command @arguments } | Should -Throw
    
                $arguments[$ValueParameter] = $Value
                $arguments.Name = ' '
    
                { & $Command @arguments } | Should -Throw
    
                $arguments.Remove('Name')
                $arguments.Url = 'ftp://localhost'
                $arguments.ApiKey = 'fixture-key'
    
                { & $Command @arguments } | Should -Throw
    
                $arguments.Url = 'http://localhost'
                $arguments.ApiKey = ' '
    
                { & $Command @arguments } | Should -Throw
                Should -Invoke Invoke-StarrApiRequest -Times 0
            }
        }

    Describe 'Command argument body' {
            BeforeEach {
                Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 7; status = 'queued' } }
            }
    
            It 'copies typed arguments without mutating the caller hashtable' {
                $commandArguments = @{
                    movieIds   = @(42, 43)
                    isNewMovie = $false
                }
    
                $result = Start-StarrCommand -InstanceName Main -CommandName RefreshMovie -Arguments $commandArguments -Confirm:$false
    
                $result.status | Should -Be 'queued'
                $commandArguments.ContainsKey('name') | Should -BeFalse
                $commandArguments.Count | Should -Be 2
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Body.name -eq 'RefreshMovie' -and $Body.movieIds.Count -eq 2 -and
                    $Body.movieIds[0] -eq 42 -and $Body.movieIds[1] -eq 43 -and
                    $Body.isNewMovie -eq $false -and $Body.Count -eq 3
                }
            }
    
            It 'rejects a reserved command name even in a case-sensitive dictionary' {
                $commandArguments = [System.Collections.Hashtable]::new([System.StringComparer]::Ordinal)
                $commandArguments['NAME'] = 'UnwantedCommand'
    
                { Start-StarrCommand -CommandName RefreshMovie -Arguments $commandArguments } | Should -Throw '*reserved name*'
                Should -Invoke Invoke-StarrApiRequest -Times 0
            }
    
            It 'supports an explicitly empty argument map' {
                Start-StarrCommand -InstanceName Main -CommandName RefreshMovie -Arguments @{} -Confirm:$false
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Body.Count -eq 1 -and $Body.name -eq 'RefreshMovie'
                }
            }
        }

    Describe 'Remove-StarrTag' {
            BeforeEach {
                Mock Invoke-StarrApiRequest
                Mock Get-StarrConfiguration { throw 'Unexpected configuration read.' }
            }
    
            It 'sends the named DELETE request' {
                Remove-StarrTag -InstanceName Main -TagId 7 -Confirm:$false
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq 'tag/7' -and $Method -eq 'DELETE' -and $ApiVersion -eq 'v3' -and
                    $ExpectedApplication.Count -eq 2 -and $ExpectedApplication -contains 'Radarr' -and
                    $ExpectedApplication -contains 'Sonarr' -and $InstanceName -eq 'Main'
                }
            }
    
            It 'supports explicit credentials' {
                Remove-StarrTag -Url 'http://localhost:8989/base' -ApiKey 'fixture-key' -TagId 7 -Confirm:$false
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Url -eq 'http://localhost:8989/base' -and $ApiKey -eq 'fixture-key' -and
                    $Endpoint -eq 'tag/7' -and $Method -eq 'DELETE'
                }
            }
    
            It 'delegates connection inference' {
                Remove-StarrTag -TagId 7 -Confirm:$false
    
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    [string]::IsNullOrEmpty($InstanceName) -and [string]::IsNullOrEmpty($Url)
                }
            }
    
            It 'does not invoke transport or read configuration under WhatIf' {
                @(Remove-StarrTag -InstanceName Main -TagId 7 -WhatIf).Count | Should -Be 0
    
                Should -Invoke Invoke-StarrApiRequest -Times 0
                Should -Invoke Get-StarrConfiguration -Times 0
            }
    
            It 'validates the tag ID and connections before transport' {
                { Remove-StarrTag -InstanceName Main -TagId 0 -Confirm:$false } | Should -Throw
                { Remove-StarrTag -InstanceName ' ' -TagId 7 -Confirm:$false } | Should -Throw
                { Remove-StarrTag -Url 'ftp://localhost' -ApiKey 'fixture-key' -TagId 7 -Confirm:$false } | Should -Throw
                { Remove-StarrTag -Url 'http://localhost' -ApiKey ' ' -TagId 7 -Confirm:$false } | Should -Throw
    
                Should -Invoke Invoke-StarrApiRequest -Times 0
            }
    
            It 'resolves a tag name before deleting the resource' {
                Mock Resolve-StarrTagId { 7 }
    
                Remove-StarrTag -InstanceName Main -TagName reviewed -Confirm:$false
    
                Should -Invoke Resolve-StarrTagId -Times 1 -Exactly -ParameterFilter {
                    $InstanceName -eq 'Main' -and $TagName -eq 'reviewed'
                }
                Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                    $Endpoint -eq 'tag/7' -and $Method -eq 'DELETE'
                }
            }
        }
}
