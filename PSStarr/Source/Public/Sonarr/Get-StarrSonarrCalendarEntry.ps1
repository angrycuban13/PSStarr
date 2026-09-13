function Get-StarrSonarrCalendarEntry {
    <#
    .SYNOPSIS
        Retrieves Sonarr calendar episode.

    .DESCRIPTION
        This function retrieves one calendar episode by its episode identifier.

    .PARAMETER InstanceName
        The optional saved instance name. When omitted, the matching instance is inferred.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER EpisodeId
        The positive Sonarr resource identifier.

    .EXAMPLE
        Get-StarrSonarrCalendarEntry -InstanceName Main -EpisodeId 42

    .EXAMPLE
        Get-StarrSonarrCalendarEntry -Url 'http://localhost:8989' -ApiKey '<api-key>' -EpisodeId 42

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
        $EpisodeId
    )

    $request = @{
        Endpoint            = "calendar/$EpisodeId"
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
