function Start-StarrRadarrMovieFileRename {
    <#
    .SYNOPSIS
        Starts renaming selected Radarr movie files.

    .DESCRIPTION
        This function submits the typed RenameFiles command to Radarr API v3. A successful response means Radarr accepted the asynchronous command, not that every file was renamed.

    .PARAMETER InstanceName
        The optional saved Radarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER MovieId
        The positive identifier of the Radarr movie that owns the files.

    .PARAMETER MovieFileId
        One or more positive Radarr movie-file identifiers to rename.

    .EXAMPLE
        Start-StarrRadarrMovieFileRename -InstanceName RadarrMain -MovieId 42 -MovieFileId 101,102

    .EXAMPLE
        Start-StarrRadarrMovieFileRename -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42 -MovieFileId 101 -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Radarr.Command]

        This function returns the accepted Radarr command resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('PSStarr.Radarr.Command')]
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
        $MovieId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $MovieFileId
    )

    $target = "Radarr movie $MovieId files $($MovieFileId -join ', ')"

    if (-not $PSCmdlet.ShouldProcess($target, 'Rename movie files')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Radarr'
        Body                = @{
            name    = 'RenameFiles'
            movieId = $MovieId
            files   = $MovieFileId
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
