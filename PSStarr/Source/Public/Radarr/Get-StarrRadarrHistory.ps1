function Get-StarrRadarrHistory {
    <#
    .SYNOPSIS
        Retrieves Radarr history.

    .DESCRIPTION
        This function retrieves paged Radarr history, history since a timestamp, or history for one movie without exposing Sonarr-only parameters.

    .PARAMETER InstanceName
        The optional saved Radarr instance name.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER Since
        Uses the history/since route beginning at this timestamp.

    .PARAMETER MovieId
        Uses the history/movie route for this movie identifier.

    .PARAMETER Page
        The one-based page for paged history.

    .PARAMETER PageSize
        The number of history records requested per page.

    .PARAMETER SortKey
        The history field used for sorting.

    .PARAMETER SortDirection
        The sort direction.

    .PARAMETER EventTypeId
        The numeric event-type identifiers used by paged history.

    .PARAMETER EventType
        The named event type used by timestamp- or movie-scoped history.

    .PARAMETER DownloadId
        Limits paged history to one download identifier.

    .PARAMETER MovieIdFilter
        Limits paged history to the supplied movie identifiers.

    .PARAMETER LanguageIdFilter
        Limits paged history to the supplied language identifiers.

    .PARAMETER QualityIdFilter
        Limits paged history to the supplied quality identifiers.

    .PARAMETER IncludeMovie
        Includes movie resources in history records.

    .EXAMPLE
        Get-StarrRadarrHistory -InstanceName RadarrMain -Page 1 -PageSize 50

    .EXAMPLE
        Get-StarrRadarrHistory -InstanceName RadarrMain -MovieId 42 -EventType grabbed

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns Radarr history responses.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'Named')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter()]
        [System.DateTime]
        $Since,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $Page,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $PageSize,

        [Parameter()]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $SortKey,

        [Parameter()]
        [ValidateSet('default', 'ascending', 'descending')]
        [System.String]
        $SortDirection,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 0 }).Count -eq 0 })]
        [System.Int32[]]
        $EventTypeId,

        [Parameter()]
        [ValidateSet('unknown', 'grabbed', 'downloadFolderImported', 'downloadFailed', 'movieFileDeleted', 'movieFolderImported', 'movieFileRenamed', 'downloadIgnored')]
        [System.String]
        $EventType,

        [Parameter()]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $DownloadId,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $MovieIdFilter,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [Alias('Languages')]
        [System.Int32[]]
        $LanguageIdFilter,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [Alias('Quality')]
        [System.Int32[]]
        $QualityIdFilter,

        [Parameter()]
        [System.Boolean]
        $IncludeMovie
    )

    $parameters = @{
        Application = 'Radarr'
    }

    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters[$parameter.Key] = $parameter.Value
    }

    Get-StarrHistory @parameters
}
