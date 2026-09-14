function Get-StarrCalendar {
    <#
    .SYNOPSIS
        Retrieves calendar records from a Starr instance.

    .DESCRIPTION
        This function retrieves calendar records from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER InstanceName
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Application
        The expected application type. Use an application-specific calendar command for a narrower parameter surface.

    .PARAMETER Start
        The beginning of the calendar range.

    .PARAMETER End
        The end of the calendar range.

    .PARAMETER Unmonitored
        Includes unmonitored resources when true.

    .PARAMETER Tags
        A comma-separated list of tag identifiers.

    .PARAMETER TagIdFilter
        A typed list of positive tag identifiers. This cannot be combined with Tags.

    .PARAMETER IncludeSeries
        Includes series data when true.

    .PARAMETER IncludeEpisodeFile
        Includes episode-file data when true.

    .PARAMETER IncludeEpisodeImages
        Includes episode images when true.

    .EXAMPLE
        Get-StarrCalendar

    .EXAMPLE
        Get-StarrCalendar -InstanceName 'Main'

    .EXAMPLE
        Get-StarrCalendar -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.CalendarEntry]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.CalendarEntry')]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Named')]
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

        [Parameter(Mandatory = $false)]
        [ValidateSet('Radarr', 'Sonarr')]
        [System.String]
        $Application,

        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $Start,

        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $End,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $Unmonitored,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Tags,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $TagIdFilter,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeSeries,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeEpisodeFile,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeEpisodeImages
    )

    $endpoint = 'calendar'

    if ($PSBoundParameters.ContainsKey('Start') -and $PSBoundParameters.ContainsKey('End') -and $Start -gt $End) {
        $message = 'Start must be earlier than or equal to End.'
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrDateRangeInvalid' -TargetObject $PSBoundParameters -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    if ($PSBoundParameters.ContainsKey('Tags') -and $PSBoundParameters.ContainsKey('TagIdFilter')) {
        $message = 'Tags and TagIdFilter cannot be combined.'
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrCalendarTagFilterConflict' -TargetObject $PSBoundParameters -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $sonarrParameters = @('IncludeSeries', 'IncludeEpisodeFile', 'IncludeEpisodeImages') | Where-Object { $PSBoundParameters.ContainsKey($_) }

    if ($Application -eq 'Radarr' -and @($sonarrParameters).Count -gt 0) {
        $message = "Radarr calendar does not support: $($sonarrParameters -join ', ')."
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrApplicationParameterMismatch' -TargetObject $sonarrParameters -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($PSBoundParameters.ContainsKey('Application')) {
        $request.ExpectedApplication = $Application
    }
    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Start                = 'start'
        End                  = 'end'
        Unmonitored          = 'unmonitored'
        Tags                 = 'tags'
        IncludeSeries        = 'includeSeries'
        IncludeEpisodeFile   = 'includeEpisodeFile'
        IncludeEpisodeImages = 'includeEpisodeImages'
    }

    foreach ($parameter in @('Start', 'End')) {
        if ($PSBoundParameters.ContainsKey($parameter)) {
            $query[$parameter.ToLowerInvariant()] = $PSBoundParameters[$parameter].ToString('o')
        }
    }

    if ($PSBoundParameters.ContainsKey('TagIdFilter')) {
        $query.tags = $TagIdFilter -join ','
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }
    if ($Application -eq 'Sonarr' -or $PSBoundParameters.ContainsKey('IncludeSeries') -or $PSBoundParameters.ContainsKey('IncludeEpisodeFile') -or $PSBoundParameters.ContainsKey('IncludeEpisodeImages')) {
        $request.ExpectedApplication = 'Sonarr'
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
