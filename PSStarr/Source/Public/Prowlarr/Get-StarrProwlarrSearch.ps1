function Get-StarrProwlarrSearch {
    <#
    .SYNOPSIS
        Retrieves Prowlarr search results.

    .DESCRIPTION
        This function searches Prowlarr indexers without downloading releases. This GET can contact indexers, consume quotas, record search history, and populate server caches. Omitting Term requests recent releases according to the selected search type and indexers.

    .PARAMETER InstanceName
        The saved Prowlarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Prowlarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Prowlarr.

    .PARAMETER Term
        The search text; omit to request recent releases.

    .PARAMETER Type
        The indexer search type. Omit to use the server default of search.

    .PARAMETER IndexerIdFilter
        The indexer identifiers to search.

    .PARAMETER CategoryIdFilter
        The Newznab category identifiers to include.

    .PARAMETER Limit
        The requested maximum results; individual indexers may impose their own limits.

    .PARAMETER Offset
        The zero-based result offset.

    .EXAMPLE
        Get-StarrProwlarrSearch -InstanceName 'Main' -Term 'Example' -IndexerIdFilter 1,2

    .EXAMPLE
        Get-StarrProwlarrSearch -Url 'http://localhost:9696' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized Prowlarr response objects.
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

        [Parameter()]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Term,

        [Parameter()]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Type,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $IndexerIdFilter,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $CategoryIdFilter,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $Limit,

        [Parameter()]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32]
        $Offset
    )

    $request = @{
        Endpoint            = 'search'
        Method              = 'GET'
        ExpectedApplication = 'Prowlarr'
        ApiVersion          = 'v1'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Term             = 'query'
        Type             = 'type'
        IndexerIdFilter  = 'indexerIds'
        CategoryIdFilter = 'categories'
        Limit            = 'limit'
        Offset           = 'offset'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }

    if ($PSBoundParameters.ContainsKey('Url')) {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
