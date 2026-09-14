function Get-StarrProwlarrIndexerStatistic {
    <#
    .SYNOPSIS
        Retrieves Prowlarr indexer statistics results.

    .DESCRIPTION
        This function retrieves Prowlarr indexer statistics without changing settings. An unbounded date range can require a large server-side statistics query. Indexer, protocol, and tag filters are sent as comma-separated strings as required by this endpoint.

    .PARAMETER InstanceName
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
        Get-StarrProwlarrIndexerStatistic -InstanceName 'Main' -IndexerIdFilter 1,2 -Protocol Torrent -Tag movies

    .EXAMPLE
        Get-StarrProwlarrIndexerStatistic -Url 'http://localhost:9696' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Prowlarr.IndexerStatistic]

        This function returns deserialized Prowlarr response objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Prowlarr.IndexerStatistic')]
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
        [ValidateSet('Unknown', 'Usenet', 'Torrent')]
        [System.String[]]
        $Protocol,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) -and $_ -notmatch ',' })]
        [System.String[]]
        $Tag
    )

    if ($PSBoundParameters.ContainsKey('StartDate') -and $PSBoundParameters.ContainsKey('EndDate') -and $StartDate -gt $EndDate) {
        $message = 'StartDate must be earlier than or equal to EndDate.'
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrDateRangeInvalid' -TargetObject $PSBoundParameters -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $request = @{
        Endpoint            = 'indexerstats'
        Method              = 'GET'
        ExpectedApplication = 'Prowlarr'
        ApiVersion          = 'v1'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        StartDate       = 'startDate'
        EndDate         = 'endDate'
        IndexerIdFilter = 'indexers'
        Protocol        = 'protocols'
        Tag             = 'tags'
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
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
