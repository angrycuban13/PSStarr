function Get-StarrRadarrMissing {
    <#
    .SYNOPSIS
        Get-Starr Radarr Missing.

    .DESCRIPTION
        This function retrieves Radarr Missing data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrRadarrMissing -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrRadarrMissing -Url 'http://localhost:7878' -ApiKey '<api-key>'

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
        $Query
    )

    $endpoint = 'wanted/missing'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Radarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





