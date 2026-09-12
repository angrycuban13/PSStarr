function Set-StarrRadarrCollectionMonitoring {
    <#
    .SYNOPSIS
        Changes Radarr collection monitoring.

    .DESCRIPTION
        This function sets monitoring on selected collections without directly changing existing movie monitoring or other collection settings. Radarr queues a collection refresh after this update; enabling monitoring can trigger configured collection automation.

    .PARAMETER Name
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER CollectionId
        One or more positive Radarr collection identifiers to update.

    .PARAMETER Monitored
        The explicit monitoring state to apply to the selected collections.

    .EXAMPLE
        Set-StarrRadarrCollectionMonitoring -Name 'Main' -CollectionId 42,43 -Monitored $true

    .EXAMPLE
        Set-StarrRadarrCollectionMonitoring -Url 'http://localhost:7878' -ApiKey '<api-key>' -CollectionId 42 -Monitored $false -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized updated collection objects from Radarr.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $CollectionId,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $Monitored
    )

    $target = 'Radarr collection IDs: ' + ($CollectionId -join ', ')

    if (-not $PSCmdlet.ShouldProcess($target, "Set collection monitored to $Monitored")) {
        return
    }

    $request = @{
        Endpoint            = 'collection'
        Method              = 'PUT'
        ExpectedApplication = 'Radarr'
        Body                = @{
            collectionIds = $CollectionId
            monitored = $Monitored
        }
    }

    if ($PSBoundParameters.ContainsKey('Url')) {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    Invoke-StarrApiRequest @request
}
