function Start-StarrRadarrCollectionRefresh {
    <#
    .SYNOPSIS
        Starts refreshing selected Radarr collections.

    .DESCRIPTION
        This function submits the typed RefreshCollections command to Radarr API v3. A successful response means Radarr accepted the asynchronous command, not that every refresh completed.

    .PARAMETER InstanceName
        The optional saved Radarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER CollectionId
        One or more positive Radarr collection identifiers to refresh.

    .EXAMPLE
        Start-StarrRadarrCollectionRefresh -InstanceName RadarrMain -CollectionId 7,8

    .EXAMPLE
        Start-StarrRadarrCollectionRefresh -Url 'http://localhost:7878' -ApiKey '<api-key>' -CollectionId 7 -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Radarr.Command]

        This function returns the accepted Radarr command resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('PSStarr.Radarr.Command')]
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $CollectionId
    )

    $target = "Radarr collections $($CollectionId -join ', ')"

    if (-not $PSCmdlet.ShouldProcess($target, 'Refresh collections')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Radarr'
        Body                = @{
            name          = 'RefreshCollections'
            collectionIds = $CollectionId
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
