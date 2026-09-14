function Get-StarrSonarrSeriesFolder {
    <#
    .SYNOPSIS
        Retrieves Sonarr calculated series folder name.

    .DESCRIPTION
        This function retrieves the folder name calculated by Sonarr for a series. It does not create or rename a folder.

    .PARAMETER InstanceName
        The optional saved instance name. When omitted, the matching instance is inferred.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER SeriesId
        The positive Sonarr series identifier. This parameter accepts an Id property from the pipeline.

    .EXAMPLE
        Get-StarrSonarrSeriesFolder -InstanceName Main -SeriesId 42

    .EXAMPLE
        Get-StarrSonarrSeriesFolder -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 42

    .EXAMPLE
        Get-StarrSonarrSeries -SeriesId 42 | Get-StarrSonarrSeriesFolder

    .INPUTS
        [System.Object]

        This function accepts objects with an Id property representing a Sonarr series.

    .OUTPUTS
        [PSStarr.Sonarr.FolderPreview]

        This function returns response objects retrieved from the Sonarr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Sonarr.FolderPreview')]
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
        $SeriesId
    )

    process {
        $request = @{
            Endpoint            = "series/$SeriesId/folder"
            Method              = 'GET'
            ExpectedApplication = 'Sonarr'
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
