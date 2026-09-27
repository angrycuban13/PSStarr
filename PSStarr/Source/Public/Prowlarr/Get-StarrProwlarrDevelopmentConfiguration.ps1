function Get-StarrProwlarrDevelopmentConfiguration {
    <#
    .SYNOPSIS
        Retrieves Prowlarr development settings.

    .DESCRIPTION
        This function retrieves Prowlarr development settings. It can retrieve settings for one configuration identifier. Treat returned settings as private application configuration.

    .PARAMETER InstanceName
        The optional saved Prowlarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Prowlarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER ConfigurationId
        The positive configuration identifier. Omit to read the current configuration.

    .EXAMPLE
        Get-StarrProwlarrDevelopmentConfiguration -InstanceName Main

    .EXAMPLE
        Get-StarrProwlarrDevelopmentConfiguration -Url 'http://localhost:9696' -ApiKey '<api-key>' -ConfigurationId 1

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Prowlarr.ApplicationConfiguration]

        This function returns Prowlarr development configuration.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Prowlarr.ApplicationConfiguration')]
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
        $ConfigurationId
    )

    $request = @{
        Endpoint            = 'config/development'
        Method              = 'GET'
        ExpectedApplication = 'Prowlarr'
        ApiVersion          = 'v1'
    }

    if ($PSBoundParameters.ContainsKey('ConfigurationId')) {
        $request.Endpoint = "config/development/$ConfigurationId"
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
