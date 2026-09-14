function Set-StarrSonarrSeriesTag {
    <#
    .SYNOPSIS
        Adds or removes tags on Sonarr series.

    .DESCRIPTION
        This function updates only series tags through the Sonarr API v3 bulk series editor. It adds or removes the supplied existing tag identifiers without replacing unrelated tags, changing monitoring settings, or moving files. WhatIf prevents the request entirely.

    .PARAMETER InstanceName
        The optional saved Sonarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER SeriesId
        The positive identifiers of the series to update.

    .PARAMETER TagId
        The positive identifiers of existing tags to add or remove. This function does not create tags.

    .PARAMETER TagName
        The exact name of one existing tag to add or remove. Use either TagId or TagName.

    .PARAMETER Action
        Add attaches the tags and Remove detaches them. Replacing all tags is intentionally unsupported.

    .EXAMPLE
        Set-StarrSonarrSeriesTag -InstanceName Main -SeriesId 42,43 -TagName reviewed -Action Add

    .EXAMPLE
        Set-StarrSonarrSeriesTag -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 42 -TagId 7,8 -Action Remove -WhatIf

        Previews removing tags without contacting Sonarr.

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Sonarr.Series]

        This function returns updated series response objects from Sonarr.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedById', SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('PSStarr.Sonarr.Series')]
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
        $SeriesId,

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

    $target = "Sonarr series $($SeriesId -join ', ')"

    if ($PSBoundParameters.ContainsKey('InstanceName')) {
        $target = "$InstanceName - $target"
    }

    $tagTarget = if ($PSCmdlet.ParameterSetName -like '*ByName') {
        $TagName
    }
    else {
        $TagId -join ', '
    }

    if (-not $PSCmdlet.ShouldProcess($target, "$Action tags $tagTarget")) {
        return
    }

    $resolvedTagId = if ($PSCmdlet.ParameterSetName -like '*ByName') {
        $resolveRequest = @{
            Application = 'Sonarr'
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
        Endpoint            = 'series/editor'
        Method              = 'PUT'
        ExpectedApplication = 'Sonarr'
        ApiVersion          = 'v3'
        Body                = @{
            seriesIds = $SeriesId
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
