function Get-StarrProwlarrIndexer {
    <#
    .SYNOPSIS
        Retrieves every configured Prowlarr indexer or one indexer by ID.

    .DESCRIPTION
        This function reads Prowlarr indexer resources through API v1. Unlike Get-StarrProwlarrIndexerStatus, the list route returns configured indexers regardless of failure state. Recognizable provider credentials are redacted from returned resources.

    .PARAMETER Name
        The optional saved Prowlarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Prowlarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER IndexerId
        The positive identifier of one configured indexer.

    .EXAMPLE
        Get-StarrProwlarrIndexer -Name ProwlarrMain

    .EXAMPLE
        Get-StarrProwlarrIndexer -Url 'http://localhost:9696' -ApiKey '<api-key>' -IndexerId 4

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns sanitized Prowlarr indexer resources.
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
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    Invoke-StarrApiRequest @request
}
