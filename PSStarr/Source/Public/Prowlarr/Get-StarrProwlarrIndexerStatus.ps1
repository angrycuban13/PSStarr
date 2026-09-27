function Get-StarrProwlarrIndexerStatus {
    <#
    .SYNOPSIS
        Retrieves Prowlarr indexer failure and backoff records.

    .DESCRIPTION
        This function retrieves Prowlarr indexer failures and temporary disablements. Use Get-StarrProwlarrIndexer to retrieve all configured indexers. An empty result normally means that Prowlarr has no recorded indexer failures or disablements.

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
