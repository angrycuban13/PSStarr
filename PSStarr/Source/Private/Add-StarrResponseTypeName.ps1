function Add-StarrResponseTypeName {
    <#
    .SYNOPSIS
        Adds stable PSStarr type names to an API response.

    .DESCRIPTION
        This function adds stable PSStarr type names without projecting or removing upstream response properties. Paged response records receive their resource type separately from the paging envelope.

    .PARAMETER Resource
        The deserialized response resource to type.

    .PARAMETER Application
        The resolved Starr application associated with the response.

    .PARAMETER Endpoint
        The normalized endpoint used to identify the response resource.

    .EXAMPLE
        Add-StarrResponseTypeName -Resource $movie -Application Radarr -Endpoint movie

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns the original response object with additional PowerShell type names.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Resource,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Radarr', 'Sonarr', 'Prowlarr')]
        [System.String]
        $Application,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Endpoint
    )

    if ($Resource -is [System.String] -or $Resource.GetType().IsValueType) {
        return $Resource
    }

    $normalizedEndpoint = $Endpoint.Trim('/').ToLowerInvariant() -replace '/[0-9]+$', ''

    $resourceType = switch -Regex ($normalizedEndpoint) {
        '^api$' { 'ApiInfo'; break }
        '^ping$' { 'Ping'; break }
        '^movie$' { 'Movie'; break }
        '^movie/[0-9]+/folder$' { 'FolderPreview'; break }
        '^moviefile$' { 'MovieFile'; break }
        '^collection$' { 'Collection'; break }
        '^series$' { 'Series'; break }
        '^series/[0-9]+/folder$' { 'FolderPreview'; break }
        '^episode$' { 'Episode'; break }
        '^episodefile$' { 'EpisodeFile'; break }
        '^tag/detail$' { 'TagUsage'; break }
        '^tag$' { 'Tag'; break }
        '^command$' { 'Command'; break }
        '^system/status$' { 'SystemStatus'; break }
        '^system/task$' { 'Task'; break }
        '^system/backup$' { 'Backup'; break }
        '^update$' { 'Update'; break }
        '^health$' { 'Health'; break }
        '^diskspace$' { 'DiskSpace'; break }
        '^qualityprofile$' { 'QualityProfile'; break }
        '^qualityprofile/schema$' { 'ProviderSchema'; break }
        '^qualitydefinition/limits$' { 'QualityDefinitionLimit'; break }
        '^qualitydefinition$' { 'QualityDefinition'; break }
        '^rootfolder$' { 'RootFolder'; break }
        '^remotepathmapping$' { 'RemotePathMapping'; break }
        '^applications/schema$' { 'ProviderSchema'; break }
        '^applications$' { 'Application'; break }
        '^appprofile/schema$' { 'ProviderSchema'; break }
        '^appprofile$' { 'ApplicationProfile'; break }
        '^indexer/schema$' { 'ProviderSchema'; break }
        '^indexer/categories$' { 'IndexerCategory'; break }
        '^indexer$' { 'Indexer'; break }
        '^indexerflag$' { 'IndexerFlag'; break }
        '^indexerstatus$' { 'IndexerStatus'; break }
        '^indexerstats$' { 'IndexerStatistic'; break }
        '^indexerproxy/schema$' { 'ProviderSchema'; break }
        '^indexerproxy$' { 'IndexerProxy'; break }
        '^downloadclient/schema$' { 'ProviderSchema'; break }
        '^downloadclient$' { 'DownloadClient'; break }
        '^notification/schema$' { 'ProviderSchema'; break }
        '^notification$' { 'Notification'; break }
        '^importlist/schema$' { 'ProviderSchema'; break }
        '^importlist/movie$' { 'ImportListMovie'; break }
        '^importlist$' { 'ImportList'; break }
        '^metadata/schema$' { 'ProviderSchema'; break }
        '^metadata$' { 'MetadataProvider'; break }
        '^autotagging/schema$' { 'ProviderSchema'; break }
        '^autotagging$' { 'AutoTagging'; break }
        '^customformat/schema$' { 'ProviderSchema'; break }
        '^customformat$' { 'CustomFormat'; break }
        '^customfilter$' { 'CustomFilter'; break }
        '^delayprofile$' { 'DelayProfile'; break }
        '^language$' { 'Language'; break }
        '^releaseprofile$' { 'ReleaseProfile'; break }
        '^queue/status$' { 'QueueStatus'; break }
        '^queue/details$' { 'QueueDetail'; break }
        '^queue$' { 'QueueItem'; break }
        '^history' { 'History'; break }
        '^blocklist' { 'BlocklistItem'; break }
        '^calendar' { 'CalendarEntry'; break }
        '^release$' { 'Release'; break }
        '^rename$' { 'RenamePreview'; break }
        '^manualimport$' { 'ManualImportItem'; break }
        'lookup$' { 'LookupResult'; break }
        '^wanted/(missing|cutoff)' { 'WantedItem'; break }
        '^log$' { 'LogEntry'; break }
        '^alttitle$' { 'AlternativeTitle'; break }
        '^credit$' { 'Credit'; break }
        '^extrafile$' { 'ExtraFile'; break }
        '^parse$' { 'ParseResult'; break }
        '^(exclusions|importlistexclusion)(/paged)?$' { 'ImportListExclusion'; break }
        '^search$' { 'SearchResult'; break }
        '^config/' { 'ApplicationConfiguration'; break }
        default { 'Resource' }
    }

    $recordsProperty = $Resource.PSObject.Properties['records']

    if ($null -ne $recordsProperty) {
        foreach ($record in @($recordsProperty.Value)) {
            if ($null -ne $record) {
                $recordTypeParameters = @{
                    Resource = $record
                    Endpoint = $normalizedEndpoint
                }

                if (-not [System.String]::IsNullOrWhiteSpace($Application)) {
                    $recordTypeParameters.Application = $Application
                }

                $null = Add-StarrResponseTypeName @recordTypeParameters
            }
        }

        $Resource.PSObject.TypeNames.Insert(0, 'PSStarr.ApiResponse')
        $Resource.PSObject.TypeNames.Insert(0, 'PSStarr.PagedResult')

        if (-not [System.String]::IsNullOrWhiteSpace($Application)) {
            $Resource.PSObject.TypeNames.Insert(0, "PSStarr.$Application.PagedResult")
        }

        return $Resource
    }

    $Resource.PSObject.TypeNames.Insert(0, 'PSStarr.ApiResponse')
    $Resource.PSObject.TypeNames.Insert(0, "PSStarr.$resourceType")

    if (-not [System.String]::IsNullOrWhiteSpace($Application)) {
        $Resource.PSObject.TypeNames.Insert(0, "PSStarr.$Application.$resourceType")
    }

    $Resource
}
