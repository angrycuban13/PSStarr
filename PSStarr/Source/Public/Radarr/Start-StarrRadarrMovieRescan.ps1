function Start-StarrRadarrMovieRescan {
    <#
    .SYNOPSIS
        Starts rescanning a Radarr movie folder.

    .DESCRIPTION
        This function submits the typed RescanMovie command to Radarr API v3. A successful response means Radarr accepted the asynchronous command, not that the rescan completed.

    .PARAMETER InstanceName
        The optional saved Radarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER MovieId
        The positive identifier of the Radarr movie to rescan.

    .EXAMPLE
        Start-StarrRadarrMovieRescan -InstanceName RadarrMain -MovieId 42

    .EXAMPLE
        Start-StarrRadarrMovieRescan -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42 -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Radarr.Command]

        This function returns the accepted Radarr command resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'Medium')]
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
        $MovieId
    )

    $target = "Radarr movie $MovieId"

    if (-not $PSCmdlet.ShouldProcess($target, 'Rescan movie folder')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Radarr'
        Body                = @{
            name    = 'RescanMovie'
            movieId = $MovieId
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
