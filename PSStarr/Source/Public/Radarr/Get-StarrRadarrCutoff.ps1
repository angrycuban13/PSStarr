function Get-StarrRadarrCutoff {
    <#
    .SYNOPSIS
        Retrieves Radarr cutoff-unmet records using the legacy command name.

    .DESCRIPTION
        This function preserves the original command name and delegates to Get-StarrRadarrCutoffUnmet, which more clearly describes the returned wanted records.

    .PARAMETER InstanceName
        The optional saved Radarr instance name.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER Page
        The one-based result page.

    .PARAMETER PageSize
        The number of records requested per page.

    .PARAMETER SortKey
        The field used to sort results.

    .PARAMETER SortDirection
        The result sort direction.

    .PARAMETER Monitored
        Limits results by monitored state.

    .EXAMPLE
        Get-StarrRadarrCutoff -InstanceName RadarrMain

    .EXAMPLE
        Get-StarrRadarrCutoff -InstanceName RadarrMain -Page 2 -PageSize 50

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns Radarr cutoff-unmet response objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'Named')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $Page,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $PageSize,

        [Parameter()]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $SortKey,

        [Parameter()]
        [ValidateSet('default', 'ascending', 'descending')]
        [System.String]
        $SortDirection,

        [Parameter()]
        [System.Boolean]
        $Monitored
    )

    Get-StarrRadarrCutoffUnmet @PSBoundParameters
}
