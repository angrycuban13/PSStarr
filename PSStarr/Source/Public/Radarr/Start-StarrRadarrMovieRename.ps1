function Start-StarrRadarrMovieRename {
    <#
    .SYNOPSIS
        Starts renaming files for selected Radarr movies.

    .DESCRIPTION
        This function submits the typed RenameMovie command to Radarr API v3. Use Get-StarrRadarrRenamePreview first to inspect proposed filenames. A successful response means Radarr accepted the asynchronous command.

    .PARAMETER Name
        The optional saved Radarr instance name. The matching instance is inferred when omitted.

    .PARAMETER Url
        The absolute Radarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER MovieId
        One or more positive movie identifiers whose files Radarr should rename.

    .EXAMPLE
        Start-StarrRadarrMovieRename -Name RadarrMain -MovieId 42,43

    .EXAMPLE
        Start-StarrRadarrMovieRename -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42 -WhatIf

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns the accepted Radarr command resource.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named', SupportsShouldProcess, ConfirmImpact = 'High')]
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
        $MovieId
    )

    $target = "Radarr movies $($MovieId -join ', ')"

    if (-not $PSCmdlet.ShouldProcess($target, 'Rename movie files')) {
        return
    }

    $request = @{
        Endpoint            = 'command'
        Method              = 'POST'
        ExpectedApplication = 'Radarr'
        Body                = @{
            name     = 'RenameMovie'
            movieIds = $MovieId
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
