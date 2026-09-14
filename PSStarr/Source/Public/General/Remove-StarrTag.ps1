function Remove-StarrTag {
    <#
    .SYNOPSIS
        Removes an application tag from Radarr or Sonarr.

    .DESCRIPTION
        This function removes an existing tag through API v3 using the shared transport. It supports confirmation and WhatIf. The application determines whether a tag that is still in use can be removed.

    .PARAMETER InstanceName
        The saved instance name. When omitted, the only configured Radarr or Sonarr instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr or Sonarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER TagId
        The positive identifier of the tag to remove.

    .PARAMETER TagName
        The exact name of the tag to remove. Use either TagId or TagName.

    .EXAMPLE
        Remove-StarrTag -InstanceName Main -TagName reviewed

    .EXAMPLE
        Remove-StarrTag -Url 'http://localhost:8989' -ApiKey '<api-key>' -TagId 7 -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        None.

        This function does not return output.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedById', SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(ParameterSetName = 'NamedById')]
        [Parameter(ParameterSetName = 'NamedByName')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitById')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitByName')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitById')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitByName')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedById')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitById')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $TagId,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedByName')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitByName')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $TagName
    )

    $tagTarget = if ($PSCmdlet.ParameterSetName -like '*ByName') {
        "tag '$TagName'"
    }
    else {
        "tag $TagId"
    }

    $target = $tagTarget

    if ($PSBoundParameters.ContainsKey('InstanceName')) {
        $target = "$InstanceName - $target"
    }

    if (-not $PSCmdlet.ShouldProcess($target, 'Remove tag')) {
        return
    }

    $resolvedTagId = if ($PSCmdlet.ParameterSetName -like '*ByName') {
        $resolveRequest = @{
            TagName = $TagName
        }

        if ($PSCmdlet.ParameterSetName -eq 'ExplicitByName') {
            $resolveRequest.Url = $Url
            $resolveRequest.ApiKey = $ApiKey
        }
        elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
            $resolveRequest.InstanceName = $InstanceName
        }

        Resolve-StarrTagId @resolveRequest
    }
    else {
        $TagId
    }

    $request = @{
        Endpoint            = "tag/$resolvedTagId"
        Method              = 'DELETE'
        ApiVersion          = 'v3'
        ExpectedApplication = @('Radarr', 'Sonarr')
    }

    if ($PSCmdlet.ParameterSetName -like 'Explicit*') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
