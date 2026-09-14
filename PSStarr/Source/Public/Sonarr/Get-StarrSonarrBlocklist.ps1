function Get-StarrSonarrBlocklist {
    <#
    .SYNOPSIS
        Retrieves Sonarr blocklist records.

    .DESCRIPTION
        This function exposes only the paged blocklist parameters supported by Sonarr.

    .PARAMETER InstanceName
        The optional saved Sonarr instance name.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Sonarr.

    .PARAMETER Page
        The one-based result page.

    .PARAMETER PageSize
        The number of records requested per page.

    .PARAMETER SortKey
        The blocklist field used for sorting.

    .PARAMETER SortDirection
        The sort direction.

    .PARAMETER SeriesIdFilter
        Limits results to the supplied series identifiers.

    .PARAMETER Protocols
        Limits results by download protocol.

    .EXAMPLE
        Get-StarrSonarrBlocklist -InstanceName SonarrMain

    .EXAMPLE
        Get-StarrSonarrBlocklist -InstanceName SonarrMain -SeriesIdFilter 42,43

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Sonarr.PagedResult]

        This function returns Sonarr blocklist responses.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Sonarr.PagedResult')]
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
        $SeriesIdFilter,

        [Parameter()]
        [ValidateSet('unknown', 'usenet', 'torrent')]
        [System.String[]]
        $Protocols
    )

    $parameters = @{
        Application = 'Sonarr'
    }

    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters[$parameter.Key] = $parameter.Value
    }

    Get-StarrBlocklist @parameters
}
