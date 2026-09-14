function Get-StarrProwlarrIndexerStatus {
    <#
    .SYNOPSIS
        Retrieves Prowlarr indexer failure and backoff records.

    .DESCRIPTION
        This function retrieves Prowlarr failure and backoff state through API v1. It does not return every configured indexer; use Get-StarrProwlarrIndexer for that inventory. An empty result normally means Prowlarr has no recorded indexer failures or temporary disablements.

    .PARAMETER InstanceName
        The saved Prowlarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .EXAMPLE
        Get-StarrProwlarrIndexerStatus -InstanceName Main

    .EXAMPLE
        Get-StarrProwlarrIndexerStatus -Url 'http://localhost:9696' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Prowlarr.IndexerStatus]

        This function returns indexer failure and backoff records.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Prowlarr.IndexerStatus')]
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
        Endpoint            = 'indexerstatus'
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

    Invoke-StarrApiRequest @request
}
