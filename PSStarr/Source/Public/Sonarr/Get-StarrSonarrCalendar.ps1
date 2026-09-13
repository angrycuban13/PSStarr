function Get-StarrSonarrCalendar {
    <#
    .SYNOPSIS
        Retrieves Sonarr calendar records.

    .DESCRIPTION
        This function exposes only Sonarr calendar parameters and provides typed tag-identifier filtering.

    .PARAMETER Name
        The optional saved Sonarr instance name.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Sonarr.

    .PARAMETER Start
        The beginning of the calendar range.

    .PARAMETER End
        The end of the calendar range.

    .PARAMETER Unmonitored
        Includes unmonitored series when true.

    .PARAMETER TagIdFilter
        Limits results to the supplied tag identifiers.

    .PARAMETER IncludeSeries
        Includes series resources in calendar records.

    .PARAMETER IncludeEpisodeFile
        Includes episode-file resources in calendar records.

    .PARAMETER IncludeEpisodeImages
        Includes episode images in calendar records.

    .EXAMPLE
        Get-StarrSonarrCalendar -Name SonarrMain

    .EXAMPLE
        Get-StarrSonarrCalendar -Name SonarrMain -Start (Get-Date) -IncludeSeries $true

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns Sonarr calendar records.
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
        [System.DateTime]
        $Start,

        [Parameter()]
        [System.DateTime]
        $End,

        [Parameter()]
        [System.Boolean]
        $Unmonitored,

        [Parameter()]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $TagIdFilter,

        [Parameter()]
        [System.Boolean]
        $IncludeSeries,

        [Parameter()]
        [System.Boolean]
        $IncludeEpisodeFile,

        [Parameter()]
        [System.Boolean]
        $IncludeEpisodeImages
    )

    $parameters = @{
        Application = 'Sonarr'
    }

    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters[$parameter.Key] = $parameter.Value
    }

    Get-StarrCalendar @parameters
}
