function Set-PSStarrInstance {
    <#
    .SYNOPSIS
        Creates or replaces a saved PSStarr instance.

    .DESCRIPTION
        This function creates or replaces a named Starr instance in persistent user configuration.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Application
        The Starr application type. Valid values are Radarr, Sonarr, and Lidarr.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER EncryptionMode
        The API-key storage mode. The default is Dpapi on Windows and None on other platforms. Aes256 requires PSSTARR_AES_KEY to contain exactly 32 Base64-encoded bytes.

    .EXAMPLE
        Set-PSStarrInstance -Name 'RadarrMain' -Application Radarr -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .EXAMPLE
        Set-PSStarrInstance -Name 'RadarrMain' -Application Radarr -Url 'http://localhost:7878' -ApiKey '<api-key>' -EncryptionMode Aes256

    .EXAMPLE
        Set-PSStarrInstance -Name 'RadarrMain' -Application Radarr -Url 'http://localhost:7878' -ApiKey '<api-key>' -EncryptionMode None

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Management.Automation.PSCustomObject]

        This function returns Starr instance configuration objects.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('Radarr', 'Sonarr', 'Prowlarr')]
        [string]
        $Application,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [ValidateSet('None', 'Dpapi', 'Aes256')]
        [System.String]
        $EncryptionMode
    )

    if ($PSBoundParameters.ContainsKey('ErrorAction')) {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $PSBoundParameters.ErrorAction
    }
    else {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $ErrorActionPreference
    }

    $ErrorActionPreference = 'Stop'

    if (-not $PSCmdlet.ShouldProcess($Name, 'Save Starr instance')) {
        return
    }

    try {
        $configuration = Import-StarrConfiguration
    }
    catch {
        $message = "Unable to load the saved Starr instance configuration. $($_.Exception.Message)"
        $message = Protect-StarrSensitiveText -Text $message -SensitiveValue @($ApiKey)
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ReadError -ErrorId 'StarrConfigurationReadFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message -SensitiveValue @($ApiKey)
        return
    }

    try {
        $encryptionParameters = @{}

        if ($PSBoundParameters.ContainsKey('EncryptionMode')) {
            $encryptionParameters.EncryptionMode = $EncryptionMode
        }

        $resolvedEncryptionMode = Resolve-StarrEncryptionMode @encryptionParameters
        $protectedApiKey = Protect-StarrConfigurationSecret -Secret $ApiKey -EncryptionMode $resolvedEncryptionMode
    }
    catch {
        $message = "Unable to protect the API key for Starr instance '$Name'. $($_.Exception.Message)"
        $message = Protect-StarrSensitiveText -Text $message -SensitiveValue @($ApiKey)
        $exception = [System.Security.Cryptography.CryptographicException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category SecurityError -ErrorId 'StarrConfigurationEncryptionFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message -SensitiveValue @($ApiKey)
        return
    }

    $configuration.Instances[$Name] = [ordered]@{
        Application = $Application
        Url         = $Url.TrimEnd('/')
        ApiKey      = $protectedApiKey
    }

    try {
        Export-Configuration -InputObject $configuration -CompanyName 'AngryCuban13' -Name 'PSStarr' -Scope User -AsHashtable
    }
    catch {
        $message = "Unable to save Starr instance '$Name'. $($_.Exception.Message)"
        $message = Protect-StarrSensitiveText -Text $message -SensitiveValue @($ApiKey)
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category WriteError -ErrorId 'StarrConfigurationWriteFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message -SensitiveValue @($ApiKey)
        return
    }

    [PSCustomObject]@{
        Name           = $Name
        Application    = $Application
        Url            = $Url.TrimEnd('/')
        ApiKey         = '********'
        EncryptionMode = $resolvedEncryptionMode
    }
}
