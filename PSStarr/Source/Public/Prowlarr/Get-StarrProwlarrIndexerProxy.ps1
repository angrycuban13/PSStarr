function Get-StarrProwlarrIndexerProxy {
    <#
    .SYNOPSIS
        Retrieves Prowlarr IndexerProxy resources.

    .DESCRIPTION
        This function retrieves Prowlarr IndexerProxy resources through API v1 using the shared transport. Provider secret values are redacted; do not submit returned objects as updates.

    .PARAMETER InstanceName
        The saved Prowlarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER IndexerProxyId
        The positive resource identifier for an individual lookup.

    .EXAMPLE
        Get-StarrProwlarrIndexerProxy -InstanceName Main

    .EXAMPLE
        Get-StarrProwlarrIndexerProxy -InstanceName Main -IndexerProxyId 1

    .EXAMPLE
        Get-StarrProwlarrIndexerProxy -Url 'http://localhost:9696' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Prowlarr.IndexerProxy]

        This function returns deserialized Prowlarr IndexerProxy resources with provider secrets redacted.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Prowlarr.IndexerProxy')]
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
        $IndexerProxyId
    )

    $request = @{
        Endpoint            = 'indexerproxy'
        Method              = 'GET'
        ApiVersion          = 'v1'
        ExpectedApplication = 'Prowlarr'
    }

    if ($PSBoundParameters.ContainsKey('IndexerProxyId')) {
        $request.Endpoint += "/$IndexerProxyId"
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
