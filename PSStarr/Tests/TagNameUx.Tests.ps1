BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe '<Command> tag-name selection' -ForEach @(
        @{
            Command             = 'Set-StarrRadarrMovieTag'
            Application         = 'Radarr'
            ResourceIdParameter = 'MovieId'
        }
        @{
            Command             = 'Set-StarrSonarrSeriesTag'
            Application         = 'Sonarr'
            ResourceIdParameter = 'SeriesId'
        }
    ) {
        BeforeEach {
            Mock Resolve-StarrTagId { 7 }
            Mock Invoke-StarrApiRequest { [pscustomobject]@{ id = 42 } }
        }

        It 'resolves an exact tag name before writing' {
            $expectedApplication = $Application
            $arguments = @{
                InstanceName = 'Main'
                TagName      = 'reviewed'
                Action       = 'Add'
                Confirm      = $false
            }
            $arguments[$ResourceIdParameter] = 42

            & $Command @arguments

            Should -Invoke Resolve-StarrTagId -Times 1 -Exactly -ParameterFilter {
                $InstanceName -eq 'Main' -and $Application -eq $expectedApplication -and $TagName -eq 'reviewed'
            }
            Should -Invoke Invoke-StarrApiRequest -Times 1 -Exactly -ParameterFilter {
                $Body.tags.Count -eq 1 -and $Body.tags[0] -eq 7 -and $Body.applyTags -eq 'add'
            }
        }

        It 'performs no lookup or write under WhatIf' {
            $arguments = @{
                InstanceName = 'Main'
                TagName      = 'reviewed'
                Action       = 'Remove'
                WhatIf       = $true
            }
            $arguments[$ResourceIdParameter] = 42

            @(& $Command @arguments).Count | Should -Be 0

            Should -Invoke Resolve-StarrTagId -Times 0
            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'stops before transport when name resolution fails' {
            Mock Resolve-StarrTagId { throw 'Tag was not found.' }
            $arguments = @{
                InstanceName = 'Main'
                TagName      = 'missing'
                Action       = 'Add'
                Confirm      = $false
            }
            $arguments[$ResourceIdParameter] = 42

            { & $Command @arguments } | Should -Throw '*not found*'

            Should -Invoke Invoke-StarrApiRequest -Times 0
        }

        It 'retains ApplyTags as an alias for Action' {
            (Get-Command $Command).Parameters.Action.Aliases | Should -Contain 'ApplyTags'
        }
    }

    Describe 'Resolve-StarrTagId' {
        BeforeEach {
            Mock Get-StarrTag
        }

        It 'matches labels case-insensitively and exactly' {
            Mock Get-StarrTag {
                @(
                    [pscustomobject]@{ id = 7; label = 'Reviewed' }
                    [pscustomobject]@{ id = 8; label = 'Reviewed Later' }
                )
            }

            Resolve-StarrTagId -InstanceName Main -Application Radarr -TagName reviewed | Should -Be 7
        }

        It 'returns a structured not-found error' {
            { Resolve-StarrTagId -InstanceName Main -Application Radarr -TagName missing } |
                Should -Throw -ErrorId 'StarrTagNotFound*'
        }

        It 'returns a structured ambiguity error' {
            Mock Get-StarrTag {
                @(
                    [pscustomobject]@{ id = 7; label = 'Reviewed' }
                    [pscustomobject]@{ id = 8; label = 'reviewed' }
                )
            }

            { Resolve-StarrTagId -InstanceName Main -Application Radarr -TagName reviewed } |
                Should -Throw -ErrorId 'StarrTagNameAmbiguous*'
        }
    }
}
