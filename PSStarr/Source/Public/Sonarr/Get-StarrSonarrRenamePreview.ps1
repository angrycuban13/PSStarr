function Get-StarrSonarrRenamePreview {
    <#
    .SYNOPSIS
        Retrieves Sonarr episode-file rename previews.

    .DESCRIPTION
        This function retrieves proposed episode-file renames for a series. This is a preview only and does not rename files.

    .PARAMETER Name
        The optional saved instance name. When omitted, the matching instance is inferred.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER SeriesId
        The positive Sonarr resource identifier.

    .PARAMETER SeasonNumber
        The season to inspect, including zero for specials. Omit to inspect all seasons.

    .EXAMPLE
        Get-StarrSonarrRenamePreview -Name Main -SeriesId 42

    .EXAMPLE
        Get-StarrSonarrRenamePreview -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 42

    .EXAMPLE
        Get-StarrSonarrRenamePreview -Name Main -SeriesId 42 -SeasonNumber 0

        Previews renames for specials only.

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Sonarr API.
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

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter()]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeasonNumber
    )

    $request = @{
        Endpoint = "rename"
        Method = 'GET'
        ExpectedApplication = 'Sonarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        SeriesId = 'seriesId'
        SeasonNumber = 'seasonNumber'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    Invoke-StarrApiRequest @request
}
