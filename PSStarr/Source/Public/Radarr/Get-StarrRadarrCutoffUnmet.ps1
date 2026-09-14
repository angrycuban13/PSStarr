function Get-StarrRadarrCutoffUnmet {
    <#
    .SYNOPSIS
        Retrieves Radarr movies that have not met their quality cutoff.

    .DESCRIPTION
        This function retrieves one page of wanted Radarr movies whose downloaded files have not met the configured quality-profile cutoff.

    .PARAMETER InstanceName
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Page
        The one-based result page.

    .PARAMETER PageSize
        The maximum number of records returned per page.

    .PARAMETER SortKey
        The field used to sort results.

    .PARAMETER SortDirection
        The result sort direction.

    .PARAMETER Monitored
        Filters results by monitored state.

    .EXAMPLE
        Get-StarrRadarrCutoffUnmet

    .EXAMPLE
        Get-StarrRadarrCutoffUnmet -InstanceName 'Main'

    .EXAMPLE
        Get-StarrRadarrCutoffUnmet -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Radarr.PagedResult], [PSStarr.Radarr.WantedItem]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Radarr.PagedResult', 'PSStarr.Radarr.WantedItem')]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Named')]
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

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $Page,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $PageSize,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $SortKey,

        [Parameter(Mandatory = $false)]
        [ValidateSet('default', 'ascending', 'descending')]
        [System.String]
        $SortDirection,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $Monitored
    )

    $endpoint = 'wanted/cutoff'

    $request = @{
        Endpoint = $endpoint
    }
    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Page          = 'page'
        PageSize      = 'pageSize'
        SortKey       = 'sortKey'
        SortDirection = 'sortDirection'
        Monitored     = 'monitored'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
    }
    $request.ExpectedApplication = 'Radarr'

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
