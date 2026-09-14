function Get-StarrRadarrRenamePreview {
    <#
    .SYNOPSIS
        Retrieves Radarr rename results.

    .DESCRIPTION
        This function retrieves proposed movie-file renames without changing filenames. Radarr inspects the selected movies to calculate naming previews.

    .PARAMETER InstanceName
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER MovieIdFilter
        One or more movie identifiers whose rename previews are requested. This parameter accepts an Id property from the pipeline.

    .EXAMPLE
        Get-StarrRadarrRenamePreview -InstanceName 'Main' -MovieIdFilter 42,43

    .EXAMPLE
        Get-StarrRadarrRenamePreview -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieIdFilter 42,43

    .EXAMPLE
        Get-StarrRadarrMovie -MovieId 42 | Get-StarrRadarrRenamePreview

    .INPUTS
        [System.Object]

        This function accepts objects with an Id property representing a Radarr movie.

    .OUTPUTS
        [PSStarr.Radarr.RenamePreview]

        This function returns deserialized Radarr response objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Radarr.RenamePreview')]
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

        [Parameter(Mandatory = $true, ParameterSetName = 'Named', ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit', ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32[]]
        $MovieIdFilter
    )

    process {
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
        elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
            $request.InstanceName = $InstanceName
        }

        Invoke-StarrApiRequest @request
    }
}
