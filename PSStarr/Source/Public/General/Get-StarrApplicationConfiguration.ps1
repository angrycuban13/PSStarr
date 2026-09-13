function Get-StarrApplicationConfiguration {
    <#
    .SYNOPSIS
        Retrieves application configuration from a Starr application.

    .DESCRIPTION
        This function retrieves a supported application configuration section, not PSStarr's saved connections. Metadata is Radarr-only; Prowlarr supports DownloadClient, Host, and Ui through this command. Host credentials are always replaced with [REDACTED]; returned host settings must not be submitted as a configuration update.

    .PARAMETER Name
        The saved instance name. When omitted, the only configured instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER Application
        The expected application type. This selects Prowlarr API v1 when required and validates section compatibility.

    .PARAMETER Section
        The application configuration section. Metadata is available only in Radarr.

    .PARAMETER ConfigurationId
        The positive identifier for the configuration resource. Omit this to retrieve the current section.

    .EXAMPLE
        Get-StarrApplicationConfiguration -Name Main -Section Naming

    .EXAMPLE
        Get-StarrApplicationConfiguration -Name Main -Section Host -ConfigurationId 1

    .EXAMPLE
        Get-StarrApplicationConfiguration -Url 'http://localhost:7878' -ApiKey '<api-key>' -Section Metadata

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized application configuration with host secrets redacted.
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

        [Parameter(Mandatory = $false)]
        [ValidateSet('Radarr', 'Sonarr', 'Prowlarr')]
        [System.String]
        $Application,

        [Parameter(Mandatory = $true)]
        [ValidateSet('DownloadClient', 'Host', 'ImportList', 'Indexer', 'MediaManagement', 'Metadata', 'Naming', 'Ui')]
        [System.String]
        $Section,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $ConfigurationId
    )

    $request = @{
        Endpoint = "config/$($Section.ToLowerInvariant())"
        Method   = 'GET'
    }

    if ($PSBoundParameters.ContainsKey('Application')) {
        $request.ExpectedApplication = $Application
    }

    $supportedSections = @{
        Radarr   = @('DownloadClient', 'Host', 'ImportList', 'Indexer', 'MediaManagement', 'Metadata', 'Naming', 'Ui')
        Sonarr   = @('DownloadClient', 'Host', 'ImportList', 'Indexer', 'MediaManagement', 'Naming', 'Ui')
        Prowlarr = @('DownloadClient', 'Host', 'Ui')
    }

    if ($PSBoundParameters.ContainsKey('Application') -and $Section -notin $supportedSections[$Application]) {
        $message = "$Application does not support the $Section configuration section."
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrConfigurationSectionNotSupported' -TargetObject $Section -Activity $MyInvocation.MyCommand.Name

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    if ($PSBoundParameters.ContainsKey('ConfigurationId')) {
        $request.Endpoint += "/$ConfigurationId"
    }

    if ($Section -eq 'Metadata') {
        $request.ExpectedApplication = 'Radarr'
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    $result = Invoke-StarrApiRequest @request

    if ($Section -ne 'Host') {
        return $result
    }

    foreach ($configuration in $result) {
        $safeConfiguration = [ordered]@{}

        foreach ($property in $configuration.PSObject.Properties) {
            if ($property.Name -in @('apiKey', 'password', 'passwordConfirmation', 'sslCertPassword', 'proxyPassword')) {
                $safeConfiguration[$property.Name] = '[REDACTED]'
            }
            else {
                $safeConfiguration[$property.Name] = $property.Value
            }
        }

        [pscustomobject]$safeConfiguration
    }
}
