function Get-StarrBlocklist {
    <#
    .SYNOPSIS
        Retrieves blocklist records from a Starr instance.

    .DESCRIPTION
        This function retrieves paged blocklist records from Radarr or Sonarr, or the Radarr blocklist for one movie.

    .PARAMETER Name
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER MovieId
        The Radarr movie identifier used with the movie blocklist endpoint.

    .PARAMETER Page
        The one-based result page.

    .PARAMETER PageSize
        The maximum number of records returned per page.

    .PARAMETER SortKey
        The field used to sort results.

    .PARAMETER SortDirection
        The result sort direction.

    .PARAMETER MovieIdFilter
        The Radarr movie identifiers used to filter the paged blocklist.

    .PARAMETER SeriesIdFilter
        The Sonarr series identifiers used to filter the paged blocklist.

    .PARAMETER Protocols
        The download protocols used to filter results.

    .EXAMPLE
        Get-StarrBlocklist

    .EXAMPLE
        Get-StarrBlocklist -Name 'RadarrMain' -MovieIdFilter 12, 34 -PageSize 50

    .EXAMPLE
        Get-StarrBlocklist -Name 'RadarrMain' -MovieId 12

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns blocklist response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Named')]
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

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $Page,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $PageSize,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $SortKey,

        [Parameter(Mandatory = $false)]
        [ValidateSet('default', 'ascending', 'descending')]
        [System.String]
        $SortDirection,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $MovieIdFilter,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $SeriesIdFilter,

        [Parameter(Mandatory = $false)]
        [ValidateSet('unknown', 'usenet', 'torrent')]
        [System.String[]]
        $Protocols
    )

    $hasRadarrParameters = $PSBoundParameters.ContainsKey('MovieId') -or $PSBoundParameters.ContainsKey('MovieIdFilter')
    $hasSonarrParameters = $PSBoundParameters.ContainsKey('SeriesIdFilter')

    if ($hasRadarrParameters -and $hasSonarrParameters) {
        $message = 'MovieId or MovieIdFilter cannot be combined with SeriesIdFilter.'
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrApplicationParameterConflict' -TargetObject $PSBoundParameters -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $request = @{
        Endpoint = 'blocklist'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Page           = 'page'
        PageSize       = 'pageSize'
        SortKey        = 'sortKey'
        SortDirection  = 'sortDirection'
        MovieIdFilter  = 'movieIds'
        SeriesIdFilter = 'seriesIds'
        Protocols      = 'protocols'
    }

    if ($PSBoundParameters.ContainsKey('MovieId')) {
        $request.Endpoint = 'blocklist/movie'
        $query.movieId = $MovieId
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }

    if ($hasRadarrParameters) {
        $request.ExpectedApplication = 'Radarr'
    }
    elseif ($hasSonarrParameters) {
        $request.ExpectedApplication = 'Sonarr'
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    Invoke-StarrApiRequest @request
}
