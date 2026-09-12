function Get-StarrSonarrCutoff {
    <#
    .SYNOPSIS
        Retrieves Sonarr cutoff-unmet records from a Starr instance.

    .DESCRIPTION
        This function retrieves Sonarr cutoff-unmet records from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER Name
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER EpisodeId
        The positive Episode resource identifier used for an individual lookup.

    .PARAMETER Page
        The one-based result page.

    .PARAMETER PageSize
        The maximum number of records returned per page.

    .PARAMETER SortKey
        The field used to sort results.

    .PARAMETER SortDirection
        The result sort direction.

    .PARAMETER IncludeSeries
        Includes series data when true.

    .PARAMETER IncludeEpisodeFile
        Includes episode-file data when true.

    .PARAMETER IncludeImages
        Includes image data when true.

    .PARAMETER Monitored
        Filters results by monitored state.

    .EXAMPLE
        Get-StarrSonarrCutoff

    .EXAMPLE
        Get-StarrSonarrCutoff -Name 'Main'

    .EXAMPLE
        Get-StarrSonarrCutoff -Url 'http://localhost:7878' -ApiKey '<api-key>'

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
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $EpisodeId,

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
        [System.Boolean]
        $IncludeSeries,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeEpisodeFile,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeImages,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $Monitored
    )

    $endpoint = 'wanted/cutoff'

    $request = @{
        Endpoint = $endpoint
    }
    if ($PSBoundParameters.ContainsKey('EpisodeId')) {
        $request.Endpoint = "$endpoint/$EpisodeId"
    }
    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Page               = 'page'
        PageSize           = 'pageSize'
        SortKey            = 'sortKey'
        SortDirection      = 'sortDirection'
        IncludeSeries      = 'includeSeries'
        IncludeEpisodeFile = 'includeEpisodeFile'
        IncludeImages      = 'includeImages'
        Monitored          = 'monitored'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }
    $request.ExpectedApplication = 'Sonarr'

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    Invoke-StarrApiRequest @request
}
