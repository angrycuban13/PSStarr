function New-StarrTag {
    <#
    .SYNOPSIS
        Creates an application tag in Radarr or Sonarr.

    .DESCRIPTION
        This function creates a tag through API v3 using the shared transport. It supports confirmation and WhatIf.

    .PARAMETER InstanceName
        The saved instance name. When omitted, the only configured instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr or Sonarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER Label
        The nonblank label for the new tag.

    .EXAMPLE
        New-StarrTag -InstanceName Main -Label 'reviewed'

    .EXAMPLE
        New-StarrTag -Url 'http://localhost:8989' -ApiKey '<api-key>' -Label 'reviewed' -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns the deserialized created tag resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'Medium')]
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
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Label
    )

    $target = if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $Url
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $InstanceName
    }
    else {
        'the inferred Starr instance'
    }

    if (-not $PSCmdlet.ShouldProcess($target, 'Create tag')) {
        return
    }

    $body = @{
        label = $Label
    }

    $request = @{
        Endpoint   = 'tag'
        Method     = 'POST'
        ApiVersion = 'v3'
        Body       = $body
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
