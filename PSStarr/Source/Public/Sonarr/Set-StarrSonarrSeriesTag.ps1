function Set-StarrSonarrSeriesTag {
    <#
    .SYNOPSIS
        Adds or removes tags on Sonarr series.

    .DESCRIPTION
        This function updates only series tags through the Sonarr API v3 bulk series editor. It adds or removes the supplied existing tag identifiers without replacing unrelated tags, changing monitoring settings, or moving files. WhatIf prevents the request entirely.

    .PARAMETER Name
        The optional saved Sonarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER SeriesId
        The positive identifiers of the series to update.

    .PARAMETER TagId
        The positive identifiers of existing tags to add or remove. This function does not create tags.

    .PARAMETER ApplyTags
        Add attaches the tags and Remove detaches them. Replacing all tags is intentionally unsupported.

    .EXAMPLE
        Set-StarrSonarrSeriesTag -Name Main -SeriesId 42,43 -TagId 7 -ApplyTags Add

    .EXAMPLE
        Set-StarrSonarrSeriesTag -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 42 -TagId 7,8 -ApplyTags Remove -WhatIf

        Previews removing tags without contacting Sonarr.

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns updated series response objects from Sonarr.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'Medium')]
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
        $SeriesId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $TagId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Add', 'Remove')]
        [System.String]
        $ApplyTags
    )

    $target = "Sonarr series $($SeriesId -join ', ')"

    if ($PSBoundParameters.ContainsKey('Name')) {
        $target = "$Name - $target"
    }

    if (-not $PSCmdlet.ShouldProcess($target, "$ApplyTags tags $($TagId -join ', ')")) {
        return
    }

    $request = @{
        Endpoint = 'series/editor'
        Method = 'PUT'
        ExpectedApplication = 'Sonarr'
        ApiVersion = 'v3'
        Body = @{
            seriesIds = $SeriesId
            tags = $TagId
            applyTags = $ApplyTags.ToLowerInvariant()
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('Name')) {
        $request.Name = $Name
    }

    Invoke-StarrApiRequest @request
}
