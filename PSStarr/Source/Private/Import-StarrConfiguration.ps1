function Import-StarrConfiguration {
    <#
    .SYNOPSIS
        Imports the persisted PSStarr configuration without decrypting secrets.

    .DESCRIPTION
        This function imports the persisted PSStarr configuration and ensures its instance collection is usable while preserving encrypted values.

    .EXAMPLE
        Import-StarrConfiguration

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Collections.Hashtable]

        This function returns the raw PSStarr configuration as a hashtable.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()

    $configuration = Import-Configuration -CompanyName 'AngryCuban13' -Name 'PSStarr'

    if ($null -eq $configuration) {
        return @{
            Instances = @{}
        }
    }

    if (-not $configuration.ContainsKey('Instances') -or $null -eq $configuration.Instances) {
        $configuration.Instances = @{}
    }

    if ($configuration.Instances -isnot [System.Collections.IDictionary]) {
        throw 'The saved Starr instance configuration is invalid. Remove it and create the instances again.'
    }

    $configuration
}
