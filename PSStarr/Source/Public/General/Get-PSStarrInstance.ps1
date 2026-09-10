function Get-PSStarrInstance {
    <#
    .SYNOPSIS
        Get-Starr Instance.

    .DESCRIPTION
        This function retrieves saved Starr instances and their encryption modes without exposing API keys.

    .PARAMETER Name
        The name of the saved Starr instance.

    .EXAMPLE
        Get-PSStarrInstance

    .EXAMPLE
        Get-PSStarrInstance -Name 'RadarrMain'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Management.Automation.PSCustomObject]

        This function returns Starr instance configuration objects.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name
    )

    if ($PSBoundParameters.ContainsKey('ErrorAction')) {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $PSBoundParameters.ErrorAction
    }
    else {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $ErrorActionPreference
    }

    $ErrorActionPreference = 'Stop'

    try {
        $configuration = Import-StarrConfiguration
    }
    catch {
        $message = "Unable to load the saved Starr instance configuration. $($_.Exception.Message)"
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ReadError -ErrorId 'StarrConfigurationReadFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        return
    }

    $instanceNames = @($configuration.Instances.Keys | Sort-Object)

    if ($PSBoundParameters.ContainsKey('Name')) {
        if (-not $configuration.Instances.Contains($Name)) {
            Write-Warning "Starr instance `"$Name`" was not found."
            return
        }

        $instanceNames = @($Name)
    }

    if ($instanceNames.Count -eq 0) {
        Write-Warning 'No Starr instances were found. Run "Set-PSStarrInstance" to create a new instance.'
        return
    }

    foreach ($instanceName in $instanceNames) {
        $instance = $configuration.Instances[$instanceName]
        $encryptionMode = if ($instance.ApiKey -is [System.Collections.IDictionary]) {
            $instance.ApiKey.Mode
        }
        else {
            'None'
        }

        [PSCustomObject]@{
            Name           = $instanceName
            Application    = $instance.Application
            Url            = $instance.Url
            ApiKey         = '********'
            EncryptionMode = $encryptionMode
        }
    }
}




