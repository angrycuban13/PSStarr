function Get-StarrRadarrBlocklist {
    <#
    .SYNOPSIS
        Retrieves Radarr blocklist records.

    .DESCRIPTION
        This function exposes only Radarr blocklist parameters, including the movie-scoped route.

    .PARAMETER InstanceName
        The optional saved Radarr instance name.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER MovieId
        Uses the Radarr blocklist route for one movie.

    .PARAMETER Page
        The one-based result page.

    .PARAMETER PageSize
        The number of records requested per page.

    .PARAMETER SortKey
        The blocklist field used for sorting.

    .PARAMETER SortDirection
        The sort direction.

    .PARAMETER MovieIdFilter
        Limits paged results to the supplied movie identifiers.

    .PARAMETER Protocols
        Limits results by download protocol.

    .EXAMPLE
        Get-StarrRadarrBlocklist -InstanceName RadarrMain

    .EXAMPLE
        Get-StarrRadarrBlocklist -InstanceName RadarrMain -MovieIdFilter 42,43

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns Radarr blocklist responses.
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
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $MovieIdFilter,

        [Parameter()]
        [ValidateSet('unknown', 'usenet', 'torrent')]
        [System.String[]]
        $Protocols
    )

    $parameters = @{
        Application = 'Radarr'
    }

    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters[$parameter.Key] = $parameter.Value
    }

    Get-StarrBlocklist @parameters
}
