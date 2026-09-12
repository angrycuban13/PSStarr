function Get-StarrLogEntry {
    <#
    .SYNOPSIS
        Retrieves application log records from a Starr instance.

    .DESCRIPTION
        This function retrieves application log records from an inferred or named Starr instance, or from an explicit URL and API key. Returns one page with paging metadata. Log content can contain sensitive operational details; protect the returned data. The current connection API key is redacted from text fields, but other secrets cannot be identified reliably.

    .PARAMETER Name
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

    .PARAMETER Level
        Filters results by the server log level.

    .EXAMPLE
        Get-StarrLogEntry

    .EXAMPLE
        Get-StarrLogEntry -Name 'Main'

    .EXAMPLE
        Get-StarrLogEntry -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Named')]
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
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Level
    )

    $endpoint = 'log'

    $request = @{
        Endpoint = $endpoint
        Method = 'GET'
    }
    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Page = 'page'
        PageSize = 'pageSize'
        SortKey = 'sortKey'
        SortDirection = 'sortDirection'
        Level = 'level'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
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
