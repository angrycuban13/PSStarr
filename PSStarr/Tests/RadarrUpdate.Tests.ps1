BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> Radarr updates' -ForEach @(
        @{ Command = 'Set-StarrRadarrMovieTag'; Resource = 'movie/editor'; Arguments = @{ MovieId = @(42,43); TagId = @(2,3); ApplyTags = 'Add' } }
        @{ Command = 'Set-StarrRadarrCollectionMonitoring'; Resource = 'collection'; Arguments = @{ CollectionId = @(42,43); Monitored = $true } }
    ) {
        BeforeEach {
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 42 } }
        }

        It 'sends PUT with a named Radarr connection and returns the response' {
            (& $Command -InstanceName Main @Arguments -Confirm:$false).id | Should -Be 42

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq $Resource -and $Method -eq 'PUT' -and $ExpectedApplication -eq 'Radarr' -and $InstanceName -eq 'Main'
            }
        }

        It 'supports explicit and inferred connections' {
            & $Command -Url 'http://localhost:7878/base' -ApiKey fixture-key @Arguments -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Url -eq 'http://localhost:7878/base' -and $ApiKey -eq 'fixture-key' -and $ExpectedApplication -eq 'Radarr'
            }

            & $Command @Arguments -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                [string]::IsNullOrEmpty($InstanceName) -and [string]::IsNullOrEmpty($Url)
            }
        }

        It 'does not invoke transport under WhatIf' {
            @(& $Command -InstanceName Main @Arguments -WhatIf).Count | Should -Be 0
            & $Command -Url 'http://localhost:7878' -ApiKey fixture-key @Arguments -WhatIf

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'validates connection values before transport' {
            { & $Command -InstanceName ' ' @Arguments } | Should -Throw
            { & $Command -Url 'ftp://localhost' -ApiKey fixture-key @Arguments } | Should -Throw
            { & $Command -Url 'http://localhost:7878' -ApiKey ' ' @Arguments } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }

    Describe 'Radarr update bodies' {
        BeforeEach {
            Mock Invoke-StarrApiRequest {}
        }

        It 'adds tags without sending unrelated settings' {
            Set-StarrRadarrMovieTag -MovieId 42,43 -TagId 2,3 -ApplyTags Add -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Body.Count -eq 3 -and ($Body.movieIds -join ',') -eq '42,43' -and
                ($Body.tags -join ',') -eq '2,3' -and $Body.applyTags -ceq 'add'
            }
        }

        It 'removes tags and preserves singleton arrays' {
            Set-StarrRadarrMovieTag -MovieId 42 -TagId 2 -ApplyTags Remove -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Body.movieIds -is [int[]] -and $Body.tags -is [int[]] -and
                $Body.movieIds[0] -eq 42 -and $Body.tags[0] -eq 2 -and $Body.applyTags -ceq 'remove'
            }
        }

        It 'sends explicit false monitoring without changing other settings' {
            Set-StarrRadarrCollectionMonitoring -CollectionId 42 -Monitored $false -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Body.Count -eq 2 -and $Body.collectionIds -is [int[]] -and
                $Body.collectionIds[0] -eq 42 -and $Body.monitored -is [bool] -and $Body.monitored -eq $false
            }
        }

        It 'sends true monitoring for all specified collections' {
            Set-StarrRadarrCollectionMonitoring -CollectionId 42,43 -Monitored $true -Confirm:$false

            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                ($Body.collectionIds -join ',') -eq '42,43' -and $Body.monitored -eq $true
            }
        }

        It 'rejects empty or invalid identifiers and tag replacement' {
            { Set-StarrRadarrMovieTag -MovieId @() -TagId 2 -ApplyTags Add } | Should -Throw
            { Set-StarrRadarrMovieTag -MovieId 42,0 -TagId 2 -ApplyTags Add } | Should -Throw
            { Set-StarrRadarrMovieTag -MovieId 42 -TagId @() -ApplyTags Add } | Should -Throw
            { Set-StarrRadarrMovieTag -MovieId 42 -TagId -1 -ApplyTags Add } | Should -Throw
            { Set-StarrRadarrMovieTag -MovieId 42 -TagId 2 -ApplyTags Replace } | Should -Throw
            { Set-StarrRadarrCollectionMonitoring -CollectionId @() -Monitored $true } | Should -Throw
            { Set-StarrRadarrCollectionMonitoring -CollectionId 42,0 -Monitored $true } | Should -Throw
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }
    }
}
