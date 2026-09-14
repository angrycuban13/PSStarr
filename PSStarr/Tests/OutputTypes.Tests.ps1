BeforeDiscovery {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

InModuleScope PSStarr {
    Describe 'API response type names' {
        BeforeEach {
            Mock Invoke-RestMethod
        }

        It 'types an application resource without removing upstream properties' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{
                    id           = 42
                    title        = 'Fixture Movie'
                    upstreamOnly = 'preserved'
                }
            }

            $result = Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey 'fixture-key' -ExpectedApplication Radarr -Endpoint movie

            $result.PSObject.TypeNames[0] | Should -Be 'PSStarr.Radarr.Movie'
            $result.PSObject.TypeNames | Should -Contain 'PSStarr.Movie'
            $result.PSObject.TypeNames | Should -Contain 'PSStarr.ApiResponse'
            $result.upstreamOnly | Should -Be 'preserved'
            $result.PSObject.Properties.Name | Should -Contain 'upstreamOnly'
        }

        It 'types a paging envelope and each record separately' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{
                    page         = 1
                    pageSize     = 10
                    totalRecords = 1
                    records      = @(
                        [pscustomobject]@{
                            id     = 7
                            status = 'queued'
                        }
                    )
                }
            }

            $result = Invoke-StarrApiRequest -Url 'http://localhost:8989' -ApiKey 'fixture-key' -ExpectedApplication Sonarr -Endpoint queue

            $result.PSObject.TypeNames[0] | Should -Be 'PSStarr.Sonarr.PagedResult'
            $result.PSObject.TypeNames | Should -Contain 'PSStarr.PagedResult'
            $result.records[0].PSObject.TypeNames[0] | Should -Be 'PSStarr.Sonarr.QueueItem'
            $result.records[0].PSObject.TypeNames | Should -Contain 'PSStarr.QueueItem'
            $result.totalRecords | Should -Be 1
        }

        It 'uses a stable fallback type for unmapped endpoints' {
            Mock Invoke-RestMethod { [pscustomobject]@{ value = 42 } }

            $result = Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey 'fixture-key' -Endpoint 'future/resource'

            $result.PSObject.TypeNames[0] | Should -Be 'PSStarr.Resource'
            $result.PSObject.TypeNames | Should -Contain 'PSStarr.ApiResponse'
        }
    }

    Describe 'Typed safe copies' {
        It 'preserves PSStarr type ordering while redacting provider fields' {
            $resource = [pscustomobject]@{
                id     = 7
                fields = @(
                    [pscustomobject]@{
                        name  = 'apiKey'
                        value = 'fixture-secret'
                    }
                )
            }
            $resource.PSObject.TypeNames.Insert(0, 'PSStarr.Prowlarr.Application')
            $resource.PSObject.TypeNames.Insert(1, 'PSStarr.Application')
            $resource.PSObject.TypeNames.Insert(2, 'PSStarr.ApiResponse')

            $result = Protect-StarrProviderResource -Resource $resource

            $result.PSObject.TypeNames[0] | Should -Be 'PSStarr.Prowlarr.Application'
            $result.PSObject.TypeNames[1] | Should -Be 'PSStarr.Application'
            $result.PSObject.TypeNames[2] | Should -Be 'PSStarr.ApiResponse'
            $result.fields[0].value | Should -Be '[REDACTED]'
        }
    }
}

Describe 'PSStarr default format data' {
    It 'loads a default view for <TypeName>' -ForEach @(
        @{ TypeName = 'PSStarr.Movie' }
        @{ TypeName = 'PSStarr.Series' }
        @{ TypeName = 'PSStarr.Command' }
        @{ TypeName = 'PSStarr.Tag' }
        @{ TypeName = 'PSStarr.Health' }
        @{ TypeName = 'PSStarr.Indexer' }
        @{ TypeName = 'PSStarr.Instance' }
        @{ TypeName = 'PSStarr.Collection' }
        @{ TypeName = 'PSStarr.Episode' }
        @{ TypeName = 'PSStarr.MovieFile' }
        @{ TypeName = 'PSStarr.EpisodeFile' }
        @{ TypeName = 'PSStarr.QualityProfile' }
        @{ TypeName = 'PSStarr.RootFolder' }
        @{ TypeName = 'PSStarr.QueueItem' }
        @{ TypeName = 'PSStarr.SystemStatus' }
        @{ TypeName = 'PSStarr.ApiInfo' }
        @{ TypeName = 'PSStarr.Task' }
        @{ TypeName = 'PSStarr.Backup' }
        @{ TypeName = 'PSStarr.DiskSpace' }
        @{ TypeName = 'PSStarr.DownloadClient' }
        @{ TypeName = 'PSStarr.Notification' }
        @{ TypeName = 'PSStarr.ImportList' }
        @{ TypeName = 'PSStarr.History' }
        @{ TypeName = 'PSStarr.BlocklistItem' }
        @{ TypeName = 'PSStarr.Release' }
        @{ TypeName = 'PSStarr.SearchResult' }
        @{ TypeName = 'PSStarr.RenamePreview' }
        @{ TypeName = 'PSStarr.ManualImportItem' }
        @{ TypeName = 'PSStarr.LookupResult' }
        @{ TypeName = 'PSStarr.WantedItem' }
        @{ TypeName = 'PSStarr.CalendarEntry' }
        @{ TypeName = 'PSStarr.LogEntry' }
        @{ TypeName = 'PSStarr.PagedResult' }
        @{ TypeName = 'PSStarr.ApplicationConfiguration' }
        @{ TypeName = 'PSStarr.ProviderSchema' }
    ) {
        Get-FormatData -TypeName $TypeName | Should -Not -BeNullOrEmpty
    }
}
