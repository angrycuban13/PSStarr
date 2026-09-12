function Get-StarrCalendar {
    <#
    .SYNOPSIS
        Retrieves calendar records from a Starr instance.

    .DESCRIPTION
        This function retrieves calendar records from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER Name
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Start
        The beginning of the calendar range.

    .PARAMETER End
        The end of the calendar range.

    .PARAMETER Unmonitored
        Includes unmonitored resources when true.

    .PARAMETER Tags
        A comma-separated list of tag identifiers.

    .PARAMETER IncludeSeries
        Includes series data when true.

    .PARAMETER IncludeEpisodeFile
        Includes episode-file data when true.

    .PARAMETER IncludeEpisodeImages
        Includes episode images when true.

    .EXAMPLE
        Get-StarrCalendar

    .EXAMPLE
        Get-StarrCalendar -Name 'Main'

    .EXAMPLE
        Get-StarrCalendar -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
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

    $request = @{
        Endpoint = $endpoint
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

    if ($query.Count -gt 0) {
        $request.Query = $query
    }
    if ($PSBoundParameters.ContainsKey('IncludeSeries') -or $PSBoundParameters.ContainsKey('IncludeEpisodeFile') -or $PSBoundParameters.ContainsKey('IncludeEpisodeImages')) {
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
