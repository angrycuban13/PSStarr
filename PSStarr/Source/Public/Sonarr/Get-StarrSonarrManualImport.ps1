function Get-StarrSonarrManualImport {
    <#
    .SYNOPSIS
        Retrieves Sonarr manual-import candidates.

    .DESCRIPTION
        This function inspects candidate files on the Sonarr host without importing them. Folder/download inspection and existing series inspection are separate operations. This GET may scan server storage and take time.

    .PARAMETER InstanceName
        The optional saved instance name. When omitted, the matching instance is inferred.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER Folder
        The folder on the Sonarr host to inspect, not a local client path.

    .PARAMETER DownloadId
        The optional download identifier associated with the folder.

    .PARAMETER FilterExistingFiles
        Whether to exclude existing files. When omitted, Sonarr defaults to true.

    .PARAMETER SeriesId
        The existing series whose files should be inspected.

    .PARAMETER SeasonNumber
        The optional season within the selected series, including zero for specials.

    .EXAMPLE
        Get-StarrSonarrManualImport -InstanceName Main -Folder '/downloads/example'

    .EXAMPLE
        Get-StarrSonarrManualImport -Url 'http://localhost:8989' -ApiKey '<api-key>' -Folder '/downloads/example'

    .EXAMPLE
        Get-StarrSonarrManualImport -InstanceName Main -SeriesId 42 -SeasonNumber 0

        Inspects existing files for the specials season without importing them.

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Sonarr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedFolder')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'NamedFolder')]
        [Parameter(ParameterSetName = 'NamedSeries')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitFolder')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeries')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitFolder')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeries')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedFolder')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitFolder')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Folder,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedFolder')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitFolder')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $DownloadId,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedFolder')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitFolder')]
        [System.Boolean]
        $FilterExistingFiles,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSeries')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeries')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedSeries')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitSeries')]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeasonNumber
    )

    $request = @{
        Endpoint            = 'manualimport'
        Method              = 'GET'
        ExpectedApplication = 'Sonarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Folder              = 'folder'
        DownloadId          = 'downloadId'
        FilterExistingFiles = 'filterExistingFiles'
        SeriesId            = 'seriesId'
        SeasonNumber        = 'seasonNumber'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }

    if ($PSCmdlet.ParameterSetName -like 'Explicit*') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
