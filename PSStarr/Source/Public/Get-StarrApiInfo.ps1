function Get-StarrApiInfo {
    <#
    .SYNOPSIS
        Get-Starr Api Info.

    .DESCRIPTION
        This function retrieves Api Info data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .EXAMPLE
        Get-StarrApiInfo -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrApiInfo -Url 'http://localhost:7878' -ApiKey '<api-key>'

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
        $ApiKey
    )

    $request = @{
        Endpoint    = 'api'
        Unversioned = $true
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



