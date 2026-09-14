function Get-StarrRadarrCalendar {
    <#
    .SYNOPSIS
        Retrieves Radarr calendar records.

    .DESCRIPTION
        This function exposes only Radarr calendar parameters and provides typed tag-identifier filtering.

    .PARAMETER InstanceName
        The optional saved Radarr instance name.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER Start
        The beginning of the calendar range.

    .PARAMETER End
        The end of the calendar range.

    .PARAMETER Unmonitored
        Includes unmonitored movies when true.

    .PARAMETER TagIdFilter
        Limits results to the supplied tag identifiers.

    .EXAMPLE
        Get-StarrRadarrCalendar -InstanceName RadarrMain

    .EXAMPLE
        Get-StarrRadarrCalendar -InstanceName RadarrMain -Start (Get-Date) -TagIdFilter 2,5

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Radarr.CalendarEntry]

        This function returns Radarr calendar records.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Radarr.CalendarEntry')]
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
        $TagIdFilter
    )

    $parameters = @{
        Application = 'Radarr'
    }

    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters[$parameter.Key] = $parameter.Value
    }

    Get-StarrCalendar @parameters
}
