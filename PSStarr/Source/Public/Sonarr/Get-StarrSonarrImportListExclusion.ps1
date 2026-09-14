function Get-StarrSonarrImportListExclusion {
    <#
    .SYNOPSIS
        Retrieves Sonarr import-list exclusions.

    .DESCRIPTION
        This function retrieves one page of Sonarr import-list exclusions or an individual exclusion by its internal ID. Paging metadata is preserved. It does not fetch all pages or use the deprecated unpaged route.

    .PARAMETER InstanceName
        The saved instance name. When omitted, the only matching Sonarr instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER ExclusionId
        The positive internal exclusion ID, not a movie or series database ID.

    .PARAMETER Page
        The one-based page to retrieve. When omitted, the server default applies.

    .PARAMETER PageSize
        The maximum records per page. When omitted, the server default applies.

    .PARAMETER SortKey
        The resource field used to sort the page.

    .PARAMETER SortDirection
        The result sort direction.

    .EXAMPLE
        Get-StarrSonarrImportListExclusion -InstanceName 'Main' -Page 2 -PageSize 20

    .EXAMPLE
        Get-StarrSonarrImportListExclusion -InstanceName 'Main' -ExclusionId 7

    .EXAMPLE
        Get-StarrSonarrImportListExclusion -Url 'http://localhost:8989' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Sonarr.PagedResult], [PSStarr.Sonarr.ImportListExclusion]

        This function returns a paging object containing records, or an individual exclusion.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedPage')]
    [OutputType('PSStarr.Sonarr.PagedResult', 'PSStarr.Sonarr.ImportListExclusion')]
    param(
        [Parameter(ParameterSetName = 'NamedPage')]
        [Parameter(ParameterSetName = 'NamedId')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitPage')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitId')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitPage')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitId')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedId')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitId')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $ExclusionId,

        [Parameter(ParameterSetName = 'NamedPage')]
        [Parameter(ParameterSetName = 'ExplicitPage')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $Page,

        [Parameter(ParameterSetName = 'NamedPage')]
        [Parameter(ParameterSetName = 'ExplicitPage')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $PageSize,

        [Parameter(ParameterSetName = 'NamedPage')]
        [Parameter(ParameterSetName = 'ExplicitPage')]
        [ValidateSet('id', 'title', 'tvdbId')]
        [System.String]
        $SortKey,

        [Parameter(ParameterSetName = 'NamedPage')]
        [Parameter(ParameterSetName = 'ExplicitPage')]
        [ValidateSet('default', 'ascending', 'descending')]
        [System.String]
        $SortDirection
    )

    $request = @{
        Endpoint            = 'importlistexclusion/paged'
        Method              = 'GET'
        ExpectedApplication = 'Sonarr'
    }

    if ($PSBoundParameters.ContainsKey('ExclusionId')) {
        $request.Endpoint = "importlistexclusion/$ExclusionId"
    }
    else {
        $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
            Page          = 'page'
            PageSize      = 'pageSize'
            SortKey       = 'sortKey'
            SortDirection = 'sortDirection'
        }

        if ($query.Count -gt 0) {
            $request.Query = $query
        }
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
