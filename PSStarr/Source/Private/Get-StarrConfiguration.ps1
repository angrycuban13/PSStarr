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

    $configuration = Import-Configuration -CompanyName 'AngryCuban13' -Name 'PSStarr'

    if ($null -eq $configuration) { return @{Instances = @{} } }

    if (-not $configuration.ContainsKey('Instances') -or $null -eq $configuration.Instances) {
        $configuration.Instances = @{}
    }

    if ($configuration.Instances -isnot [System.Collections.IDictionary]) {
        throw 'The saved Starr instance configuration is invalid. Remove it and create the instances again.'
    }

    $configuration
}







