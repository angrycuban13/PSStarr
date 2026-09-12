function Get-StarrRadarrImportListMovie {
    <#
    .SYNOPSIS
        Retrieves Radarr import list movie results.

    .DESCRIPTION
        This function retrieves discovered movies from enabled import lists. Optional recommendation, trending, and popular results can cause Radarr to contact external metadata services; this command does not add movies.

    .PARAMETER Name
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER IncludeRecommendations
        Includes recommended movies.

    .PARAMETER IncludeTrending
        Includes trending movies.

    .PARAMETER IncludePopular
        Includes popular movies.

    .EXAMPLE
        Get-StarrRadarrImportListMovie -Name 'Main' -IncludeTrending $true

    .EXAMPLE
        Get-StarrRadarrImportListMovie -Url 'http://localhost:7878' -ApiKey '<api-key>' -IncludeTrending $true

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
        [System.Boolean]
        $IncludeRecommendations,

        [Parameter(ParameterSetName = 'Named')]
        [Parameter(ParameterSetName = 'Explicit')]
        [System.Boolean]
        $IncludeTrending,

        [Parameter(ParameterSetName = 'Named')]
        [Parameter(ParameterSetName = 'Explicit')]
        [System.Boolean]
        $IncludePopular
    )

    $request = @{
        Endpoint            = 'importlist/movie'
        Method              = 'GET'
        ExpectedApplication = 'Radarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        IncludeRecommendations = 'includeRecommendations'
        IncludeTrending        = 'includeTrending'
        IncludePopular         = 'includePopular'
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
