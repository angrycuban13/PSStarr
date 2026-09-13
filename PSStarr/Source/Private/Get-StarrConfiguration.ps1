function Get-StarrConfiguration {
    <#
    .SYNOPSIS
        Retrieves the persisted PSStarr configuration.

    .DESCRIPTION
        This function retrieves the persisted PSStarr configuration and ensures its instance collection is usable.

    .EXAMPLE
        Get-StarrConfiguration

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Collections.Hashtable]

        This function returns the PSStarr configuration as a hashtable.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()

    $persistedConfiguration = Import-StarrConfiguration
    $configuration = @{
        Instances = @{}
    }

    foreach ($instanceName in $persistedConfiguration.Instances.Keys) {
        $persistedInstance = $persistedConfiguration.Instances[$instanceName]

        $configuration.Instances[$instanceName] = [ordered]@{
            Application = $persistedInstance.Application
            Url         = $persistedInstance.Url
            ApiKey      = Unprotect-StarrConfigurationSecret -Value $persistedInstance.ApiKey
        }
    }

    $configuration
}
