function Get-StarrRadarrMovieFolder {
    <#
    .SYNOPSIS
        Retrieves Radarr movie folder results.

    .DESCRIPTION
        This function retrieves the computed folder name for a movie using Radarr naming settings. It does not list files, create folders, or move movies.

    .PARAMETER Name
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER MovieId
        The movie identifier whose folder name is calculated.

    .EXAMPLE
        Get-StarrRadarrMovieFolder -Name 'Main' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrMovieFolder -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42

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
        [System.Int32]
        $MovieId
    )

    $request = @{
        Endpoint            = "movie/$MovieId/folder"
        Method              = 'GET'
        ExpectedApplication = 'Radarr'
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
