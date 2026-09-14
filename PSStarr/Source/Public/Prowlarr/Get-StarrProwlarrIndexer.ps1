function Get-StarrProwlarrIndexer {
    <#
    .SYNOPSIS
        Retrieves every configured Prowlarr indexer or one indexer by ID.

    .DESCRIPTION
        This function reads Prowlarr indexer resources through API v1. Unlike Get-StarrProwlarrIndexerStatus, the list route returns configured indexers regardless of failure state. Recognizable provider credentials are redacted from returned resources.

    .PARAMETER InstanceName
        The optional saved Prowlarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Prowlarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER IndexerId
        The positive identifier of one configured indexer.

    .EXAMPLE
        Get-StarrProwlarrIndexer -InstanceName ProwlarrMain

    .EXAMPLE
        Get-StarrProwlarrIndexer -Url 'http://localhost:9696' -ApiKey '<api-key>' -IndexerId 4

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Prowlarr.Indexer]

        This function returns sanitized Prowlarr indexer resources.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Prowlarr.Indexer')]
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
        $IndexerId
    )

    $request = @{
        Endpoint            = 'indexer'
        Method              = 'GET'
        ApiVersion          = 'v1'
        ExpectedApplication = 'Prowlarr'
    }

    if ($PSBoundParameters.ContainsKey('IndexerId')) {
        $request.Endpoint = "indexer/$IndexerId"
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
