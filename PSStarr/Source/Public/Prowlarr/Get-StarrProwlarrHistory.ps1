function Get-StarrProwlarrHistory {
    <#
    .SYNOPSIS
        Retrieves Prowlarr history.

    .DESCRIPTION
        This function retrieves one page of history, history since a timestamp, or history for one indexer through Prowlarr API v1. Selectors and filters for different routes cannot be mixed. Returned history can contain private search terms and download identifiers.

    .PARAMETER Name
        The optional saved Prowlarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Prowlarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER Since
        The timestamp selecting history/since. It is sent in round-trip format.

    .PARAMETER IndexerId
        The positive indexer identifier selecting history/indexer.

    .PARAMETER Page
        The one-based page to retrieve. No additional pages are fetched automatically.

    .PARAMETER PageSize
        The maximum records in the requested page.

    .PARAMETER SortKey
        The paged-history sort field. Prowlarr currently supports date only.

    .PARAMETER SortDirection
        The paged-history sort direction.

    .PARAMETER EventTypeId
        The numeric event types filtering paged history.

    .PARAMETER Successful
        Filters paged history by success or failure, including an explicit false value.

    .PARAMETER DownloadId
        The download identifier filtering paged history.

    .PARAMETER IndexerIdFilter
        The positive indexer identifiers filtering paged history.

    .PARAMETER EventType
        The named event type filtering date-scoped or indexer-scoped history.

    .PARAMETER Limit
        The maximum number of records returned for one indexer.

    .EXAMPLE
        Get-StarrProwlarrHistory -Name Main -Page 2 -PageSize 50 -Successful $false

    .EXAMPLE
        Get-StarrProwlarrHistory -Name Main -Since ([datetime]'2026-01-01T00:00:00Z') -EventType indexerQuery

    .EXAMPLE
        Get-StarrProwlarrHistory -Url 'http://localhost:9696' -ApiKey '<api-key>' -IndexerId 7 -Limit 20

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns a paging response or history records from Prowlarr.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedPaged')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'NamedPaged')]
        [Parameter(ParameterSetName = 'NamedSince')]
        [Parameter(ParameterSetName = 'NamedIndexer')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitPaged')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitIndexer')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitPaged')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitIndexer')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSince')]
        [System.DateTime]
        $Since,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedIndexer')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitIndexer')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $IndexerId,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedPaged')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitPaged')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $Page,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedPaged')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitPaged')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $PageSize,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedPaged')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitPaged')]
        [ValidateSet('date')]
        [System.String]
        $SortKey,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedPaged')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitPaged')]
        [ValidateSet('default', 'ascending', 'descending')]
        [System.String]
        $SortDirection,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedPaged')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitPaged')]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $EventTypeId,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedPaged')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitPaged')]
        [System.Boolean]
        $Successful,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedPaged')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitPaged')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $DownloadId,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedPaged')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitPaged')]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $IndexerIdFilter,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedSince')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitSince')]
        [Parameter(Mandatory = $false, ParameterSetName = 'NamedIndexer')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitIndexer')]
        [ValidateSet('unknown', 'releaseGrabbed', 'indexerQuery', 'indexerRss', 'indexerAuth', 'indexerInfo')]
        [System.String]
        $EventType,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedIndexer')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitIndexer')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $Limit
    )

    $request = @{
        Endpoint = 'history'
        Method = 'GET'
        ExpectedApplication = 'Prowlarr'
        ApiVersion = 'v1'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Page = 'page'
        PageSize = 'pageSize'
        SortKey = 'sortKey'
        SortDirection = 'sortDirection'
        EventTypeId = 'eventType'
        Successful = 'successful'
        DownloadId = 'downloadId'
        IndexerIdFilter = 'indexerIds'
        IndexerId = 'indexerId'
        EventType = 'eventType'
        Limit = 'limit'
    }

    if ($PSBoundParameters.ContainsKey('Since')) {
        $request.Endpoint = 'history/since'
        $query.date = $Since.ToString('o')
    }
    elseif ($PSBoundParameters.ContainsKey('IndexerId')) {
        $request.Endpoint = 'history/indexer'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }

    if ($PSCmdlet.ParameterSetName -like 'Explicit*') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    Invoke-StarrApiRequest @request
}
