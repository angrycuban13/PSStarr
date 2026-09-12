function Get-StarrRadarrRenamePreview {
    <#
    .SYNOPSIS
        Retrieves Radarr rename results.

    .DESCRIPTION
        This function retrieves proposed movie-file renames without changing filenames. Radarr inspects the selected movies to calculate naming previews.

    .PARAMETER Name
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER MovieIdFilter
        One or more movie identifiers whose rename previews are requested.

    .EXAMPLE
        Get-StarrRadarrRenamePreview -Name 'Main' -MovieIdFilter 42,43

    .EXAMPLE
        Get-StarrRadarrRenamePreview -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieIdFilter 42,43

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized Radarr response objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
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

        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $MovieIdFilter
    )

    $request = @{
        Endpoint            = 'rename'
        Method              = 'GET'
        ExpectedApplication = 'Radarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        MovieIdFilter = 'movieId'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
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
