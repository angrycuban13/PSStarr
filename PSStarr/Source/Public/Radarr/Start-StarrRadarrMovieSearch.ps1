function Start-StarrRadarrMovieSearch {
    <#
    .SYNOPSIS
        Starts a Radarr search for selected movies.

    .DESCRIPTION
        This function submits the typed MoviesSearch command to Radarr API v3. A successful response means Radarr accepted the asynchronous command, not that searching completed.

    .PARAMETER InstanceName
        The optional saved Radarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER MovieId
        One or more positive movie identifiers to search.

    .EXAMPLE
        Start-StarrRadarrMovieSearch -InstanceName RadarrMain -MovieId 42,43

    .EXAMPLE
        Start-StarrRadarrMovieSearch -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42 -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns the accepted Radarr command resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'Medium')]
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $MovieId
    )

    $target = "Radarr movies $($MovieId -join ', ')"

    if (-not $PSCmdlet.ShouldProcess($target, 'Start movie search')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Radarr'
        Body                = @{
            name     = 'MoviesSearch'
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
