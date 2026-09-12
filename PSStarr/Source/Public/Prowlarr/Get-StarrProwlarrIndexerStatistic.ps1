function Get-StarrProwlarrIndexerStatistic {
    <#
    .SYNOPSIS
        Retrieves Prowlarr indexer statistics results.

    .DESCRIPTION
        This function retrieves Prowlarr indexer statistics without changing settings. An unbounded date range can require a large server-side statistics query. Indexer, protocol, and tag filters are sent as comma-separated strings as required by this endpoint.

    .PARAMETER Name
        The saved Prowlarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Prowlarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Prowlarr.

    .PARAMETER StartDate
        The beginning of the statistics interval; omitted values use the server default.

    .PARAMETER EndDate
        The end of the statistics interval; omitted values use the server default.

    .PARAMETER IndexerIdFilter
        The indexer identifiers to include.

    .PARAMETER Protocol
        The download protocols to include.

    .PARAMETER Tag
        Existing tag labels or numeric tag identifiers to include. Commas within a tag are not accepted.

    .EXAMPLE
        Get-StarrProwlarrIndexerStatistic -Name 'Main' -IndexerIdFilter 1,2 -Protocol Torrent -Tag movies

    .EXAMPLE
        Get-StarrProwlarrIndexerStatistic -Url 'http://localhost:9696' -ApiKey '<api-key>'

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
        [System.DateTime]
        $StartDate,

        [Parameter()]
        [System.DateTime]
        $EndDate,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $IndexerIdFilter,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Usenet', 'Torrent')]
        [System.String[]]
        $Protocol,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) -and $_ -notmatch ',' })]
        [System.String[]]
        $Tag
    )

    $request = @{
        Endpoint            = 'indexerstats'
        Method              = 'GET'
        ExpectedApplication = 'Prowlarr'
        ApiVersion          = 'v1'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        StartDate = 'startDate'
        EndDate = 'endDate'
        IndexerIdFilter = 'indexers'
        Protocol = 'protocols'
        Tag = 'tags'
    }

    foreach ($parameter in @('StartDate', 'EndDate')) {
        if ($PSBoundParameters.ContainsKey($parameter)) {
            $query[$parameter.Substring(0, 1).ToLowerInvariant() + $parameter.Substring(1)] = $PSBoundParameters[$parameter].ToString('o')
        }
    }

    foreach ($key in @('indexers', 'protocols', 'tags')) {
        if ($query.ContainsKey($key)) {
            $query[$key] = $query[$key] -join ','
        }
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }

    if ($PSBoundParameters.ContainsKey('Url')) {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    Invoke-StarrApiRequest @request
}
