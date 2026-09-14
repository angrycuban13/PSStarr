function Get-StarrProwlarrApplication {
    <#
    .SYNOPSIS
        Retrieves applications configured for synchronization from Prowlarr.

    .DESCRIPTION
        This function retrieves configured application integrations that Prowlarr synchronizes with, such as Radarr or Sonarr. Provider secret values are redacted; do not submit returned objects as updates.

    .PARAMETER InstanceName
        The saved Prowlarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER ApplicationId
        The positive resource identifier for an individual lookup.

    .EXAMPLE
        Get-StarrProwlarrApplication -InstanceName Main

    .EXAMPLE
        Get-StarrProwlarrApplication -InstanceName Main -ApplicationId 1

    .EXAMPLE
        Get-StarrProwlarrApplication -Url 'http://localhost:9696' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Prowlarr.Application]

        This function returns deserialized Prowlarr Application resources with provider secrets redacted.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Prowlarr.Application')]
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

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $ApplicationId
    )

    $request = @{
        Endpoint            = 'applications'
        Method              = 'GET'
        ApiVersion          = 'v1'
        ExpectedApplication = 'Prowlarr'
    }

    if ($PSBoundParameters.ContainsKey('ApplicationId')) {
        $request.Endpoint += "/$ApplicationId"
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    foreach ($resource in (Invoke-StarrApiRequest @request)) {
        Protect-StarrProviderResource -Resource $resource
    }
}
