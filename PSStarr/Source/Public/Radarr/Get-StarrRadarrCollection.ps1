function Get-StarrRadarrCollection {
    <#
    .SYNOPSIS
        Retrieves Radarr collections from a Starr instance.

    .DESCRIPTION
        This function retrieves Radarr collections from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER InstanceName
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER CollectionId
        The positive Collection resource identifier used for an individual lookup.

    .PARAMETER TmdbId
        The TMDB identifier used to filter results.

    .EXAMPLE
        Get-StarrRadarrCollection

    .EXAMPLE
        Get-StarrRadarrCollection -InstanceName 'Main'

    .EXAMPLE
        Get-StarrRadarrCollection -Url 'http://localhost:7878' -ApiKey '<api-key>'

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
        $CollectionId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $TmdbId
    )

    $endpoint = 'collection'

    $request = @{
        Endpoint = $endpoint
    }
    if ($PSBoundParameters.ContainsKey('CollectionId')) {
        $request.Endpoint = "$endpoint/$CollectionId"
    }
    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        TmdbId = 'tmdbId'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }
    $request.ExpectedApplication = 'Radarr'

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
