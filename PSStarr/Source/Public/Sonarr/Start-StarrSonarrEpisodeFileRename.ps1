function Start-StarrSonarrEpisodeFileRename {
    <#
    .SYNOPSIS
        Starts renaming selected Sonarr episode files.

    .DESCRIPTION
        This function submits the typed RenameFiles command to Sonarr API v3. Use Get-StarrSonarrRenamePreview first to inspect proposed filenames. A successful response means Sonarr accepted the asynchronous command.

    .PARAMETER InstanceName
        The optional saved Sonarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER SeriesId
        The positive identifier of the series that owns the files.

    .PARAMETER EpisodeFileId
        One or more positive episode-file identifiers to rename.

    .EXAMPLE
        Start-StarrSonarrEpisodeFileRename -InstanceName SonarrMain -SeriesId 42 -EpisodeFileId 100,101

    .EXAMPLE
        Start-StarrSonarrEpisodeFileRename -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 42 -EpisodeFileId 100 -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Sonarr.Command]

        This function returns the accepted Sonarr command resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('PSStarr.Sonarr.Command')]
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

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $EpisodeFileId
    )

    $target = "Sonarr episode files $($EpisodeFileId -join ', ')"

    if (-not $PSCmdlet.ShouldProcess($target, 'Rename episode files')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Sonarr'
        Body                = @{
            name     = 'RenameFiles'
            seriesId = $SeriesId
            files    = $EpisodeFileId
        }
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
