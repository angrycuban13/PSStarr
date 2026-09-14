function Get-StarrProwlarrAppProfile {
    <#
    .SYNOPSIS
        Retrieves Prowlarr application profiles.

    .DESCRIPTION
        This function retrieves application profiles that control how Prowlarr synchronizes indexers with connected applications.

    .PARAMETER InstanceName
        The saved Prowlarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER AppProfileId
        The positive resource identifier for an individual lookup.

    .EXAMPLE
        Get-StarrProwlarrAppProfile -InstanceName Main

    .EXAMPLE
        Get-StarrProwlarrAppProfile -InstanceName Main -AppProfileId 1

    .EXAMPLE
        Get-StarrProwlarrAppProfile -Url 'http://localhost:9696' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Prowlarr.ApplicationProfile]

        This function returns deserialized Prowlarr AppProfile resources.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Prowlarr.ApplicationProfile')]
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
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $AppProfileId
    )

    $request = @{
        Endpoint            = 'appprofile'
        Method              = 'GET'
        ApiVersion          = 'v1'
        ExpectedApplication = 'Prowlarr'
    }

    if ($PSBoundParameters.ContainsKey('AppProfileId')) {
        $request.Endpoint += "/$AppProfileId"
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
