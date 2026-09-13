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
        The movie identifier whose folder name is calculated. This parameter accepts an Id property from the pipeline.

    .EXAMPLE
        Get-StarrRadarrMovieFolder -Name 'Main' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrMovieFolder -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrMovie -MovieId 42 | Get-StarrRadarrMovieFolder

    .INPUTS
        [System.Object]

        This function accepts objects with an Id property representing a Radarr movie.

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

        [Parameter(Mandatory = $true, ParameterSetName = 'Named', ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit', ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId
    )

    process {
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
}
