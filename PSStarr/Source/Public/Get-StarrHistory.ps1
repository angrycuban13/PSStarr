function Get-StarrHistory {
    <#
    .SYNOPSIS
        Retrieves history from a Starr instance.

    .DESCRIPTION
        This function retrieves history from a named Starr instance or an explicit URL and API key, optionally scoped by date or application resource.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Since
        The earliest history timestamp to retrieve.

    .PARAMETER MovieId
        The numeric Radarr movie identifier.

    .PARAMETER SeriesId
        The numeric Sonarr series identifier.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrHistory -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrHistory -Name 'RadarrMain' -MovieId 42

    .EXAMPLE
        Get-StarrHistory -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 7

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns history response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedMovie')]
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSeries')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitMovie')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeries')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitMovie')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeries')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSince')]
        [System.DateTime]
        $Since,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedMovie')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitMovie')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSeries')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeries')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]
        $Query
    )

    $endpoint = 'history'

    $request = @{
        Endpoint = $endpoint
        Query    = @{}
    }

    if ($null -ne $Query) {
        $request.Query = $Query.Clone()
    }

    if ($PSBoundParameters.ContainsKey('Since')) {
        $request.Endpoint = "$endpoint/since"
        $request.Query.Date = $Since.ToString('o')
    }

    if ($PSBoundParameters.ContainsKey('MovieId')) {
        $request.Endpoint = "$endpoint/movie"
        $request.Query.MovieId = $MovieId
        $request.ExpectedApplication = 'Radarr'
    }

    if ($PSBoundParameters.ContainsKey('SeriesId')) {
        $request.Endpoint = "$endpoint/series"
        $request.Query.SeriesId = $SeriesId
        $request.ExpectedApplication = 'Sonarr'
    }

    if ($PSCmdlet.ParameterSetName -like 'Named*') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}
