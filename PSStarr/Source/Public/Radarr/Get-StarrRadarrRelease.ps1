function Get-StarrRadarrRelease {
    <#
    .SYNOPSIS
        Retrieves Radarr release results.

    .DESCRIPTION
        This function retrieves available releases through Radarr. A movie identifier performs an indexer search; omitting it fetches RSS releases. These requests can contact indexers and update server caches, but do not download releases.

    .PARAMETER Name
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER MovieId
        The movie identifier to search; omit to fetch RSS releases.

    .EXAMPLE
        Get-StarrRadarrRelease -Name 'Main' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrRelease -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrRelease -Name 'Main'

        Fetches RSS releases instead of searching for a specific movie.

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized Radarr response objects.
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

        [Parameter(ParameterSetName = 'Named')]
        [Parameter(ParameterSetName = 'Explicit')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId
    )

    $request = @{
        Endpoint            = 'release'
        Method              = 'GET'
        ExpectedApplication = 'Radarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        MovieId = 'movieId'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }

    if ($PSBoundParameters.ContainsKey('Url')) {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    Invoke-StarrApiRequest @request
}
