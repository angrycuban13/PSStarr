function Get-StarrSonarrRenamePreview {
    <#
    .SYNOPSIS
        Retrieves Sonarr episode-file rename previews.

    .DESCRIPTION
        This function retrieves proposed episode-file renames for a series. This is a preview only and does not rename files.

    .PARAMETER InstanceName
        The optional saved instance name. When omitted, the matching instance is inferred.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER SeriesId
        The positive Sonarr series identifier. This parameter accepts an Id property from the pipeline.

    .PARAMETER SeasonNumber
        The season to inspect, including zero for specials. Omit to inspect all seasons.

    .EXAMPLE
        Get-StarrSonarrRenamePreview -InstanceName Main -SeriesId 42

    .EXAMPLE
        Get-StarrSonarrRenamePreview -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 42

    .EXAMPLE
        Get-StarrSonarrRenamePreview -InstanceName Main -SeriesId 42 -SeasonNumber 0

        Previews renames for specials only.

    .EXAMPLE
        Get-StarrSonarrSeries -SeriesId 42 | Get-StarrSonarrRenamePreview

    .INPUTS
        [System.Object]

        This function accepts objects with an Id property representing a Sonarr series.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Sonarr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'Named')]
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

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter()]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeasonNumber
    )

    process {
        $request = @{
            Endpoint            = 'rename'
            Method              = 'GET'
            ExpectedApplication = 'Sonarr'
        }

        $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
            SeriesId     = 'seriesId'
            SeasonNumber = 'seasonNumber'
        }

        if ($query.Count -gt 0) {
            $request.Query = $query
        }

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
