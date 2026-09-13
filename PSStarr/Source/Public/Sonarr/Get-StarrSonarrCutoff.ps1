function Get-StarrSonarrCutoff {
    <#
    .SYNOPSIS
        Retrieves Sonarr cutoff-unmet records using the legacy command name.

    .DESCRIPTION
        This function preserves the original command name and delegates to Get-StarrSonarrCutoffUnmet, which more clearly describes the returned wanted records.

    .PARAMETER Name
        The optional saved Sonarr instance name.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Sonarr.

    .PARAMETER EpisodeId
        Retrieves the cutoff-unmet record for one episode.

    .PARAMETER Page
        The one-based result page.

    .PARAMETER PageSize
        The number of records requested per page.

    .PARAMETER SortKey
        The field used to sort results.

    .PARAMETER SortDirection
        The result sort direction.

    .PARAMETER IncludeSeries
        Includes series resources in returned records.

    .PARAMETER IncludeEpisodeFile
        Includes episode-file resources in returned records.

    .PARAMETER IncludeImages
        Includes image metadata in returned records.

    .PARAMETER Monitored
        Limits results by monitored state.

    .EXAMPLE
        Get-StarrSonarrCutoff -Name SonarrMain

    .EXAMPLE
        Get-StarrSonarrCutoff -Name SonarrMain -EpisodeId 42

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns Sonarr cutoff-unmet response objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Name,

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
        $EpisodeId,

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
        [System.Boolean]
        $IncludeSeries,

        [Parameter()]
        [System.Boolean]
        $IncludeEpisodeFile,

        [Parameter()]
        [System.Boolean]
        $IncludeImages,

        [Parameter()]
        [System.Boolean]
        $Monitored
    )

    Get-StarrSonarrCutoffUnmet @PSBoundParameters
}
