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

    .PARAMETER ApplyTags
        Whether to add or remove the selected tags. Other tags are preserved.

    .EXAMPLE
        Set-StarrRadarrMovieTag -InstanceName 'Main' -MovieId 42,43 -TagId 2 -ApplyTags Add

    .EXAMPLE
        Set-StarrRadarrMovieTag -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42 -TagId 2 -ApplyTags Remove -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized updated movie objects from Radarr.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $MovieId,

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

    $target = 'Radarr movie IDs: ' + ($MovieId -join ', ')

    if (-not $PSCmdlet.ShouldProcess($target, "$ApplyTags selected movie tags")) {
        return
    }

    $request = @{
        Endpoint            = 'movie/editor'
        Method              = 'PUT'
        ExpectedApplication = 'Radarr'
        Body                = @{
            movieIds = $MovieId
            tags = $TagId
            applyTags = $ApplyTags.ToLowerInvariant()
        }
    }

    if ($PSBoundParameters.ContainsKey('Url')) {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
