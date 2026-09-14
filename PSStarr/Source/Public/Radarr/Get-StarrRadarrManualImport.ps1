function Get-StarrRadarrManualImport {
    <#
    .SYNOPSIS
        Retrieves Radarr manual import results.

    .DESCRIPTION
        This function inspects import candidates on the Radarr server without importing them. Inspection can scan server disks and read media files. Folder is a server-side path. A MovieId without DownloadId selects existing movie files; Radarr ignores Folder and FilterExistingFiles in that case.

    .PARAMETER InstanceName
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER Folder
        The folder on the Radarr server to inspect.

    .PARAMETER DownloadId
        The download-client identifier to inspect.

    .PARAMETER MovieId
        The movie identifier to inspect.

    .PARAMETER FilterExistingFiles
        Whether to omit existing files; omitted values retain the server default of true.

    .EXAMPLE
        Get-StarrRadarrManualImport -InstanceName 'Main' -Folder '/downloads/movies'

    .EXAMPLE
        Get-StarrRadarrManualImport -InstanceName 'Main' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrManualImport -Url 'http://localhost:7878' -ApiKey '<api-key>' -Folder '/downloads/movies'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Radarr.ManualImportItem]

        This function returns deserialized Radarr response objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Radarr.ManualImportItem')]
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

        [Parameter(ParameterSetName = 'Named')]
        [Parameter(ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Folder,

        [Parameter(ParameterSetName = 'Named')]
        [Parameter(ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $DownloadId,

        [Parameter(ParameterSetName = 'Named')]
        [Parameter(ParameterSetName = 'Explicit')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId,

        [Parameter(ParameterSetName = 'Named')]
        [Parameter(ParameterSetName = 'Explicit')]
        [System.Boolean]
        $FilterExistingFiles
    )

    $request = @{
        Endpoint            = 'manualimport'
        Method              = 'GET'
        ExpectedApplication = 'Radarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Folder              = 'folder'
        DownloadId          = 'downloadId'
        MovieId             = 'movieId'
        FilterExistingFiles = 'filterExistingFiles'
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
