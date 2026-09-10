function Get-StarrDelayProfile {
    <#
    .SYNOPSIS
        Retrieves delay profile settings from Radarr or Sonarr.

    .DESCRIPTION
        This function retrieves delay profile settings using an inferred or named instance, or explicit connection credentials.

    .PARAMETER Name
        The saved instance name. When omitted, the only configured instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER DelayProfileId
        The positive resource identifier for an individual delay profile.

    .EXAMPLE
        Get-StarrDelayProfile -Name 'Main'

    .EXAMPLE
        Get-StarrDelayProfile -Name 'Main' -DelayProfileId 1

    .EXAMPLE
        Get-StarrDelayProfile -Url 'http://localhost:8989' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized delay profile objects.
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

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $DelayProfileId
    )

    $request = @{
        Endpoint = 'delayprofile'
        Method   = 'GET'
    }

    if ($PSBoundParameters.ContainsKey('DelayProfileId')) {
        $request.Endpoint = "delayprofile/$DelayProfileId"
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
