function Set-StarrRadarrMovieTag {
    <#
    .SYNOPSIS
        Adds or removes tags on Radarr movies.

    .DESCRIPTION
        This function adds or removes selected tags without replacing other movie tags or changing other movie settings. It delegates the bulk update to the shared HTTP transport.

    .PARAMETER InstanceName
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER MovieId
        One or more positive Radarr movie identifiers to update.

    .PARAMETER TagId
        One or more existing positive tag identifiers to add or remove.

    .PARAMETER TagName
        The exact name of one existing tag to add or remove. Use either TagId or TagName.

    .PARAMETER Action
        Whether to add or remove the selected tags. Other tags are preserved.

    .EXAMPLE
        Set-StarrRadarrMovieTag -InstanceName 'Main' -MovieId 42,43 -TagName reviewed -Action Add

    .EXAMPLE
        Set-StarrRadarrMovieTag -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42 -TagId 2 -Action Remove -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Radarr.Movie]

        This function returns deserialized updated movie objects from Radarr.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedById', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType('PSStarr.Radarr.Movie')]
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $MovieId,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedById')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitById')]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $TagId,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedByName')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitByName')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $TagName,

        [Parameter(Mandatory = $true)]
        [Alias('ApplyTags')]
        [ValidateSet('Add', 'Remove')]
        [System.String]
        $Action
    )

    $target = 'Radarr movie IDs: ' + ($MovieId -join ', ')

    if (-not $PSCmdlet.ShouldProcess($target, "$Action selected movie tags")) {
        return
    }

    $resolvedTagId = if ($PSCmdlet.ParameterSetName -like '*ByName') {
        $resolveRequest = @{
            Application = 'Radarr'
            TagName     = $TagName
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
        Endpoint            = 'movie/editor'
        Method              = 'PUT'
        ExpectedApplication = 'Radarr'
        Body                = @{
            movieIds  = $MovieId
            tags      = [System.Int32[]] @($resolvedTagId)
            applyTags = $Action.ToLowerInvariant()
        }
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
