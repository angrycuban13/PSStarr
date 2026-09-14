function Start-StarrRadarrMovieRefresh {
    <#
    .SYNOPSIS
        Starts metadata refreshes for selected Radarr movies.

    .DESCRIPTION
        This function submits the typed RefreshMovie command to Radarr API v3. A successful response means Radarr accepted the asynchronous command, not that every refresh completed.

    .PARAMETER InstanceName
        The optional saved Radarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER MovieId
        One or more positive Radarr movie identifiers to refresh.

    .EXAMPLE
        Start-StarrRadarrMovieRefresh -InstanceName RadarrMain -MovieId 42

    .EXAMPLE
        Start-StarrRadarrMovieRefresh -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42,43 -WhatIf

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
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $MovieId
    )

    $target = "Radarr movies $($MovieId -join ', ')"

    if (-not $PSCmdlet.ShouldProcess($target, 'Refresh movie metadata')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Radarr'
        Body                = @{
            name     = 'RefreshMovie'
            movieIds = $MovieId
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
