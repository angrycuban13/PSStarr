function Get-StarrRadarrAlternativeTitle {
    <#
    .SYNOPSIS
        Retrieves Radarr alternative titles.

    .DESCRIPTION
        This function retrieves Radarr alternative titles through the shared transport. Use AlternativeTitleId for an individual title, or movie filters for a list.

    .PARAMETER InstanceName
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER MovieId
        The positive Radarr movie identifier used to filter records. This parameter accepts an Id property from the pipeline.

    .PARAMETER MovieMetadataId
        The positive Radarr movie metadata identifier used to filter records.

    .PARAMETER AlternativeTitleId
        The positive internal alternative-title identifier used for an individual lookup.

    .EXAMPLE
        Get-StarrRadarrAlternativeTitle -InstanceName 'Main' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrAlternativeTitle -InstanceName 'Main' -AlternativeTitleId 7

    .EXAMPLE
        Get-StarrRadarrAlternativeTitle -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrMovie -MovieId 42 | Get-StarrRadarrAlternativeTitle

    .INPUTS
        [System.Object]

        This function accepts objects with an Id property representing a Radarr movie.

    .OUTPUTS
        [System.Object]

        This function returns deserialized alternative titles.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedList')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'NamedList')]
        [Parameter(ParameterSetName = 'NamedId')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitList')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitId')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitList')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitId')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(ParameterSetName = 'NamedList', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'ExplicitList', ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId,

        [Parameter(ParameterSetName = 'NamedList')]
        [Parameter(ParameterSetName = 'ExplicitList')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieMetadataId,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedId')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitId')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $AlternativeTitleId
    )

    process {
        $request = @{
            Endpoint            = 'alttitle'
            Method              = 'GET'
            ExpectedApplication = 'Radarr'
        }

        if ($PSBoundParameters.ContainsKey('AlternativeTitleId')) {
            $request.Endpoint = "alttitle/$AlternativeTitleId"
        }

        $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
            MovieId         = 'movieId'
            MovieMetadataId = 'movieMetadataId'
        }

        if ($query.Count -gt 0) {
            $request.Query = $query
        }

        if ($PSBoundParameters.ContainsKey('Url')) {
            $request.Url = $Url
            $request.ApiKey = $ApiKey
        }
        elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
            $request.InstanceName = $InstanceName
        }

        Invoke-StarrApiRequest @request
    }
}
