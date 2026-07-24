function Set-StarrInstance {
    <#
    .SYNOPSIS
        Set-Starr Instance.

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

    .EXAMPLE
        Set-StarrInstance -Name 'RadarrMain' -Application Radarr -Url 'http://localhost:7878' -ApiKey '<api-key>'

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
        [ValidateSet('Radarr', 'Sonarr', 'Lidarr')]
        [string]
        $Application,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey
    )

    if ($PSBoundParameters.ContainsKey('ErrorAction')) {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $PSBoundParameters.ErrorAction
    }
    else {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $ErrorActionPreference
    }

    $ErrorActionPreference = 'Stop'

    try {
        $configuration = Get-StarrConfiguration
    }
    catch {
        $message = "Unable to load the saved Starr instance configuration. $($_.Exception.Message)"
        $message = Protect-StarrSensitiveText -Text $message -SensitiveValue @($ApiKey)
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ReadError -ErrorId 'StarrConfigurationReadFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message -SensitiveValue @($ApiKey)
        return
    }

    $configuration.Instances[$Name] = [ordered]@{
        Application = $Application
        Url         = $Url.TrimEnd('/')
        ApiKey      = $ApiKey
    }

    if (-not $PSCmdlet.ShouldProcess($Name, 'Save Starr instance')) {
        return
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
        Name        = $Name
        Application = $Application
        Url         = $Url.TrimEnd('/')
        ApiKey      = '********'
    }
}






