BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> required write operations' -ForEach @(
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
                $Name -eq 'Main' -and $Body -is [System.Collections.Hashtable] -and
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
                [string]::IsNullOrEmpty($Name) -and [string]::IsNullOrEmpty($Url)
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
                movieIds = @(42, 43)
                isNewMovie = $false
            }

            $result = Start-StarrCommand -Name Main -CommandName RefreshMovie -Arguments $commandArguments -Confirm:$false

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
            Start-StarrCommand -Name Main -CommandName RefreshMovie -Arguments @{} -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Body.Count -eq 1 -and $Body.name -eq 'RefreshMovie'
            }
        }
    }
}
