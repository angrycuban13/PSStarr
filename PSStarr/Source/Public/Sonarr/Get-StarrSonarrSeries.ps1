function Get-StarrSonarrSeries {
    <#
    .SYNOPSIS
        Retrieves Sonarr series from a Starr instance.

    .DESCRIPTION
        This function retrieves Sonarr series from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER InstanceName
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER SeriesId
        The positive Series resource identifier used for an individual lookup.

    .PARAMETER TvdbId
        The TVDB identifier used to filter results.

    .PARAMETER IncludeSeasonImages
        Includes Sonarr season images when true.

    .EXAMPLE
        Get-StarrSonarrSeries

    .EXAMPLE
        Get-StarrSonarrSeries -InstanceName 'Main'

    .EXAMPLE
        Get-StarrSonarrSeries -Url 'http://localhost:7878' -ApiKey '<api-key>'

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
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $TvdbId,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $IncludeSeasonImages
    )

    $endpoint = 'series'

    $request = @{
        Endpoint = $endpoint
    }
    if ($PSBoundParameters.ContainsKey('SeriesId')) {
        $request.Endpoint = "$endpoint/$SeriesId"
    }
    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        TvdbId              = 'tvdbId'
        IncludeSeasonImages = 'includeSeasonImages'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }
    $request.ExpectedApplication = 'Sonarr'

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
