function Start-StarrSonarrEpisodeSearch {
    <#
    .SYNOPSIS
        Starts a Sonarr search for selected episodes.

    .DESCRIPTION
        This function submits the typed EpisodeSearch command to Sonarr API v3. The search contacts configured indexers and can consume provider quotas; a successful response means Sonarr accepted the asynchronous command, not that releases were found or downloaded.

    .PARAMETER InstanceName
        The optional saved Sonarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Sonarr.

    .PARAMETER EpisodeId
        One or more positive Sonarr episode identifiers to search.

    .EXAMPLE
        Start-StarrSonarrEpisodeSearch -InstanceName SonarrMain -EpisodeId 101,102

    .EXAMPLE
        Start-StarrSonarrEpisodeSearch -Url 'http://localhost:8989' -ApiKey '<api-key>' -EpisodeId 101 -WhatIf

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
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $EpisodeId
    )

    $target = "Sonarr episodes $($EpisodeId -join ', ')"

    if (-not $PSCmdlet.ShouldProcess($target, 'Search episodes')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Sonarr'
        Body                = @{
            name       = 'EpisodeSearch'
            episodeIds = $EpisodeId
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
