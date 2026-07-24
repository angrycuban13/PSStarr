function Remove-StarrInstance {
    <#
    .SYNOPSIS
        Removes a saved Starr instance.

    .DESCRIPTION
        This function removes a saved Starr instance and cleans up empty configuration directories.

    .PARAMETER Name
        The name of the saved Starr instance.

    .EXAMPLE
        Remove-StarrInstance -Name 'RadarrMain' -Confirm:$false

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        None.

        This function does not return objects to the pipeline.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.Void])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
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
        $configuration = Get-StarrConfiguration
    }
    catch {
        $message = "Unable to load the saved Starr instance configuration. $($_.Exception.Message)"
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ReadError -ErrorId 'StarrConfigurationReadFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        return
    }

    if (-not $configuration.Instances.Contains($Name)) {
        Write-Warning "Starr instance '$Name' was not found."
        return
    }

    if (-not $PSCmdlet.ShouldProcess($Name, 'Remove Starr instance')) {
        return
    }

    $configuration.Instances.Remove($Name)

    if ($configuration.Instances.Count -gt 0) {
        try {
            Export-Configuration -InputObject $configuration -CompanyName 'AngryCuban13' -Name 'PSStarr' -Scope User -AsHashtable
        }
        catch {
            $message = "Unable to save the Starr instance configuration after removing '$Name'. $($_.Exception.Message)"
            $exception = [System.InvalidOperationException]::new($message, $_.Exception)
            $errorRecord = New-StarrErrorRecord -Exception $exception -Category WriteError -ErrorId 'StarrConfigurationWriteFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

            Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        }

        return
    }

    $module = Get-Module -Name PSStarr

    if ($null -eq $module) {
        $message = 'Unable to resolve the loaded PSStarr module.'
        $exception = [System.InvalidOperationException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ResourceUnavailable -ErrorId 'StarrModuleNotLoaded' -TargetObject 'PSStarr' -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        return
    }

    try {
        $configurationPath = $module | Get-ConfigurationPath -Scope User -SkipCreatingFolder
        $configurationFile = Join-Path -Path $configurationPath -ChildPath 'Configuration.psd1'
        $authorPath = Split-Path -Path $configurationPath -Parent
    }
    catch {
        $message = "Unable to resolve the PSStarr configuration path. $($_.Exception.Message)"
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ReadError -ErrorId 'StarrConfigurationPathFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        return
    }

    if ((Split-Path -Path $configurationPath -Leaf) -ne $module.Name -or
        (Split-Path -Path $authorPath -Leaf) -ne $module.CompanyName) {
        $message = "Configuration returned an unexpected path: '$configurationPath'."
        $exception = [System.InvalidOperationException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidData -ErrorId 'StarrConfigurationPathInvalid' -TargetObject $configurationPath -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        return
    }

    try {
        if (Test-Path -LiteralPath $configurationFile -PathType Leaf) {
            Remove-Item -LiteralPath $configurationFile -Force -ErrorAction Stop
        }

        foreach ($directory in @($configurationPath, $authorPath)) {
            if (Test-Path -LiteralPath $directory -PathType Container) {
                $children = @(Get-ChildItem -LiteralPath $directory -Force -ErrorAction Stop)

                if ($children.Count -eq 0) {
                    Remove-Item -LiteralPath $directory -Force -ErrorAction Stop
                }
            }
        }
    }
    catch {
        $message = "Unable to remove the final Starr instance configuration. $($_.Exception.Message)"
        $exception = [System.IO.IOException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category WriteError -ErrorId 'StarrConfigurationRemoveFailed' -TargetObject $configurationPath -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
    }
}
