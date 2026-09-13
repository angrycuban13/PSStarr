function Get-StarrRadarrExtraFile {
    <#
    .SYNOPSIS
        Retrieves Radarr extra-file records.

    .DESCRIPTION
        This function retrieves Radarr extra-file records through the shared transport. It returns file information, not file contents.

    .PARAMETER InstanceName
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER MovieId
        The positive Radarr movie identifier used to filter records. This parameter accepts an Id property from the pipeline.

    .EXAMPLE
        Get-StarrRadarrExtraFile -InstanceName 'Main' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrExtraFile -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrMovie -MovieId 42 | Get-StarrRadarrExtraFile

    .INPUTS
        [System.Object]

        This function accepts objects with an Id property representing a Radarr movie.

    .OUTPUTS
        [System.Object]

        This function returns deserialized extra-file records.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedList')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'NamedList')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitList')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitList')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(ParameterSetName = 'NamedList', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'ExplicitList', ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId
    )

    process {
        $request = @{
            Endpoint            = 'extrafile'
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
        elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
            $request.InstanceName = $InstanceName
        }

        Invoke-StarrApiRequest @request
    }
}
