function Set-PSStarrInstance {
    <#
    .SYNOPSIS
        Creates or updates a saved PSStarr instance.

    .DESCRIPTION
        This function creates or updates a named Starr instance in persistent user configuration. New instances require Application, Url, and ApiKey. Existing instances can update any subset of those values or change the API-key encryption mode.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Application
        The Starr application type. Valid values are Radarr, Sonarr, and Prowlarr.

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

    .EXAMPLE
        Set-PSStarrInstance -Name 'RadarrMain' -Url 'http://localhost:7879'

    .EXAMPLE
        Set-PSStarrInstance -Name 'RadarrMain' -EncryptionMode Aes256

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Instance]

        This function returns a redacted saved-instance configuration object.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('PSStarr.Instance')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet('Radarr', 'Sonarr', 'Prowlarr')]
        [string]
        $Application,

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $false, Position = 3)]
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

    $instanceExists = $configuration.Instances.Contains($Name)

    if (-not $instanceExists) {
        $missingParameters = @('Application', 'Url', 'ApiKey').Where({ -not $PSBoundParameters.ContainsKey($_) })

        if ($missingParameters.Count -gt 0) {
            $message = "A new Starr instance requires these parameters: $($missingParameters -join ', ')."
            $exception = [System.ArgumentException]::new($message)
            $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrConfigurationRequiredParameterMissing' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

            Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction
            return
        }
    }

    if ($PSBoundParameters.ContainsKey('ApiKey') -and $ApiKey -eq '********') {
        $message = 'The redacted API-key placeholder cannot be saved as an API key.'
        $exception = [System.ArgumentException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrConfigurationRedactedApiKeyRejected' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction
        return
    }

    if ($instanceExists) {
        $existingInstance = $configuration.Instances[$Name]

        if ($PSBoundParameters.ContainsKey('Application')) {
            $resolvedApplication = $Application
        }
        else {
            $resolvedApplication = $existingInstance.Application
        }

        if ($PSBoundParameters.ContainsKey('Url')) {
            $resolvedUrl = $Url.TrimEnd('/')
        }
        else {
            $resolvedUrl = $existingInstance.Url
        }

        if ($existingInstance.ApiKey -is [System.Collections.IDictionary]) {
            $existingEncryptionMode = $existingInstance.ApiKey.Mode
        }
        else {
            $existingEncryptionMode = 'None'
        }
    }
    else {
        $resolvedApplication = $Application
        $resolvedUrl = $Url.TrimEnd('/')
        $existingEncryptionMode = $null
    }

    $plainApiKey = $null

    try {
        if ($PSBoundParameters.ContainsKey('EncryptionMode')) {
            $resolvedEncryptionMode = Resolve-StarrEncryptionMode -EncryptionMode $EncryptionMode
        }
        elseif ($instanceExists) {
            $resolvedEncryptionMode = $existingEncryptionMode
        }
        else {
            $resolvedEncryptionMode = Resolve-StarrEncryptionMode
        }

        if ($PSBoundParameters.ContainsKey('ApiKey')) {
            $plainApiKey = $ApiKey
            $protectedApiKey = Protect-StarrConfigurationSecret -Secret $plainApiKey -EncryptionMode $resolvedEncryptionMode
        }
        elseif ($PSBoundParameters.ContainsKey('EncryptionMode')) {
            $plainApiKey = Unprotect-StarrConfigurationSecret -Value $existingInstance.ApiKey
            $protectedApiKey = Protect-StarrConfigurationSecret -Secret $plainApiKey -EncryptionMode $resolvedEncryptionMode
        }
        else {
            $protectedApiKey = $existingInstance.ApiKey
        }
    }
    catch {
        $message = "Unable to protect the API key for Starr instance '$Name'. $($_.Exception.Message)"
        $message = Protect-StarrSensitiveText -Text $message -SensitiveValue @($ApiKey, $plainApiKey)
        $exception = [System.Security.Cryptography.CryptographicException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category SecurityError -ErrorId 'StarrConfigurationEncryptionFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message -SensitiveValue @($ApiKey, $plainApiKey)
        return
    }

    $configuration.Instances[$Name] = [ordered]@{
        Application = $resolvedApplication
        Url         = $resolvedUrl
        ApiKey      = $protectedApiKey
    }

    try {
        Export-Configuration -InputObject $configuration -CompanyName 'AngryCuban13' -Name 'PSStarr' -Scope User -AsHashtable
    }
    catch {
        $message = "Unable to save Starr instance '$Name'. $($_.Exception.Message)"
        $message = Protect-StarrSensitiveText -Text $message -SensitiveValue @($ApiKey, $plainApiKey)
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category WriteError -ErrorId 'StarrConfigurationWriteFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message -SensitiveValue @($ApiKey, $plainApiKey)
        return
    }

    $outputInstance = [PSCustomObject]@{
        Name           = $Name
        Application    = $resolvedApplication
        Url            = $resolvedUrl
        ApiKey         = '********'
        EncryptionMode = $resolvedEncryptionMode
    }

    $outputInstance.PSObject.TypeNames.Insert(0, 'PSStarr.Instance')

    $outputInstance
}
