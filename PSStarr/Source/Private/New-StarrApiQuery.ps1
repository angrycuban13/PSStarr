function New-StarrApiQuery {
    <#
    .SYNOPSIS
        Creates a Starr API query from bound command parameters.

    .DESCRIPTION
        This function maps documented PowerShell parameters to their Starr API query-string names.

    .PARAMETER BoundParameters
        The calling command's bound parameter dictionary.

    .PARAMETER ParameterMap
        A mapping of PowerShell parameter names to Starr API query names.

    .EXAMPLE
        New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{ SeriesId = 'seriesId' }

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Collections.Hashtable]

        This function returns a hashtable containing only documented parameters supplied by the caller.
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'This function only constructs an in-memory query hashtable.')]
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $BoundParameters,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $ParameterMap
    )

    $query = @{}

    foreach ($parameterName in $ParameterMap.Keys) {
        if ($BoundParameters.Keys -contains $parameterName) {
            $query[$ParameterMap[$parameterName]] = $BoundParameters[$parameterName]
        }
    }

    return $query
}
