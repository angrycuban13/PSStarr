function Get-StarrRadarrMovieFile {
    <#
    .SYNOPSIS
        Retrieves Radarr movie files from a Starr instance.

    .DESCRIPTION
        This function retrieves Radarr movie files from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER Name
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER MovieFileId
        The positive MovieFile resource identifier used for an individual lookup.

    .PARAMETER MovieIdFilter
        The Radarr movie identifiers used to filter results. This parameter accepts an Id property from the pipeline.

    .PARAMETER MovieFileIdFilter
        The Radarr movie-file identifiers used to filter results.

    .EXAMPLE
        Get-StarrRadarrMovieFile

    .EXAMPLE
        Get-StarrRadarrMovieFile -Name 'Main'

    .EXAMPLE
        Get-StarrRadarrMovieFile -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .EXAMPLE
        Get-StarrRadarrMovie -MovieId 123 | Get-StarrRadarrMovieFile

    .INPUTS
        [System.Object]

        This function accepts objects with an Id property representing a Radarr movie.

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
        $MovieFileId,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $MovieIdFilter,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ @($_).Count -gt 0 -and @($_ | Where-Object { $_ -lt 1 }).Count -eq 0 })]
        [System.Int32[]]
        $MovieFileIdFilter
    )

    process {
        $endpoint = 'moviefile'

        $request = @{
            Endpoint = $endpoint
        }

        if ($PSBoundParameters.ContainsKey('MovieFileId')) {
            $request.Endpoint = "$endpoint/$MovieFileId"
        }

        $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
            MovieIdFilter = 'movieId'
            MovieFileIdFilter = 'movieFileIds'
        }

        if ($query.Count -gt 0) {
            $request.Query = $query
        }

        $request.ExpectedApplication = 'Radarr'

        if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
            $request.Url = $Url
            $request.ApiKey = $ApiKey
        }
        elseif ($PSBoundParameters.ContainsKey('Name')) {
            $request.Name = $Name
        }

        Invoke-StarrApiRequest @request
    }
}
