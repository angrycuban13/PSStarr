function Get-StarrProwlarrIndexerProxySchema {
    <#
    .SYNOPSIS
        Retrieves Prowlarr IndexerProxySchema resources.

    .DESCRIPTION
        This function retrieves schemas for Prowlarr indexer proxies. It redacts provider secrets. Do not use returned objects for updates.

    .PARAMETER InstanceName
        The saved Prowlarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .EXAMPLE
        Get-StarrProwlarrIndexerProxySchema -InstanceName Main

    .EXAMPLE
        Get-StarrProwlarrIndexerProxySchema -Url 'http://localhost:9696' -ApiKey 'example-api-key'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Prowlarr.ProviderSchema]

        This function returns deserialized Prowlarr IndexerProxySchema resources with provider secrets redacted.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Prowlarr.ProviderSchema')]
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
        $ApiKey
    )

    $request = @{
        Endpoint            = 'indexerproxy/schema'
        Method              = 'GET'
        ApiVersion          = 'v1'
        ExpectedApplication = 'Prowlarr'
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
