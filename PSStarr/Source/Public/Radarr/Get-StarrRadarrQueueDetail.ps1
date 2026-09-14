function Get-StarrRadarrQueueDetail {
    <#
    .SYNOPSIS
        Retrieves Radarr queue details.

    .DESCRIPTION
        This function exposes only the queue-detail parameters supported by Radarr.

    .PARAMETER InstanceName
        The optional saved Radarr instance name.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER MovieId
        Limits results to one movie identifier.

    .PARAMETER IncludeMovie
        Includes movie resources in queue-detail records.

    .EXAMPLE
        Get-StarrRadarrQueueDetail -InstanceName RadarrMain

    .EXAMPLE
        Get-StarrRadarrQueueDetail -InstanceName RadarrMain -MovieId 42 -IncludeMovie $true

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Radarr.QueueDetail]

        This function returns Radarr queue-detail records.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Radarr.QueueDetail')]
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
        $MovieId,

        [Parameter()]
        [System.Boolean]
        $IncludeMovie
    )

    $parameters = @{
        Application = 'Radarr'
    }

    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters[$parameter.Key] = $parameter.Value
    }

    Get-StarrQueueDetail @parameters
}
