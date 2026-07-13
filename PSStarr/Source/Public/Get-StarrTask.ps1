function Get-StarrTask {
    <#
    .SYNOPSIS
        Get-Starr Task.

    .DESCRIPTION
        This function retrieves Task data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrTask -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrTask -Url 'http://localhost:7878' -ApiKey '<api-key>'

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
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'system/task'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





