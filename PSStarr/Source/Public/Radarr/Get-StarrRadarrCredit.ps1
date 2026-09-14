function Get-StarrRadarrCredit {
    <#
    .SYNOPSIS
        Retrieves Radarr credits from a Starr instance.

    .DESCRIPTION
        This function retrieves Radarr credits from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER InstanceName
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER CreditId
        The positive Credit resource identifier used for an individual lookup.

    .PARAMETER MovieId
        The Radarr movie identifier used to filter results. This parameter accepts an Id property from the pipeline.

    .PARAMETER MovieMetadataId
        The Radarr movie metadata identifier used to filter results.

    .EXAMPLE
        Get-StarrRadarrCredit

    .EXAMPLE
        Get-StarrRadarrCredit -InstanceName 'Main'

    .EXAMPLE
        Get-StarrRadarrCredit -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .EXAMPLE
        Get-StarrRadarrMovie -MovieId 123 | Get-StarrRadarrCredit

    .INPUTS
        [System.Object]

        This function accepts objects with an Id property representing a Radarr movie.

    .OUTPUTS
        [PSStarr.Radarr.Credit]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Radarr.Credit')]
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
        $CreditId,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieMetadataId
    )

    process {
        $endpoint = 'credit'

        $request = @{
            Endpoint = $endpoint
        }

        if ($PSBoundParameters.ContainsKey('CreditId')) {
            $request.Endpoint = "$endpoint/$CreditId"
        }

        $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
            MovieId         = 'movieId'
            MovieMetadataId = 'movieMetadataId'
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
}
