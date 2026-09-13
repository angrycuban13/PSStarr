function Get-StarrSonarrQueueDetail {
    <#
    .SYNOPSIS
        Retrieves Sonarr queue details.

    .DESCRIPTION
        This function exposes only the queue-detail parameters supported by Sonarr.

    .PARAMETER InstanceName
        The optional saved Sonarr instance name.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Sonarr.

    .PARAMETER SeriesId
        Limits results to one series identifier.

    .PARAMETER EpisodeIdFilter
        Limits results to the supplied episode identifiers.

    .PARAMETER IncludeSeries
        Includes series resources in queue-detail records.

    .PARAMETER IncludeEpisode
        Includes episode resources in queue-detail records.

    .EXAMPLE
        Get-StarrSonarrQueueDetail -InstanceName SonarrMain

    .EXAMPLE
        Get-StarrSonarrQueueDetail -InstanceName SonarrMain -SeriesId 42 -IncludeEpisode $true

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns Sonarr queue-detail records.
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
        $SeriesId,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $EpisodeIdFilter,

        [Parameter()]
        [System.Boolean]
        $IncludeSeries,

        [Parameter()]
        [System.Boolean]
        $IncludeEpisode
    )

    $parameters = @{
        Application = 'Sonarr'
    }

    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters[$parameter.Key] = $parameter.Value
    }

    Get-StarrQueueDetail @parameters
}
