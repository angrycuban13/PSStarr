function Get-StarrRadarrParse {
    <#
    .SYNOPSIS
        Retrieves Radarr parse results.

    .DESCRIPTION
        This function asks Radarr to parse a release title and return recognized movie information without adding or downloading the movie.

    .PARAMETER InstanceName
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER Title
        The release title to parse.

    .EXAMPLE
        Get-StarrRadarrParse -InstanceName 'Main' -Title 'Example.Movie.2024.1080p'

    .EXAMPLE
        Get-StarrRadarrParse -Url 'http://localhost:7878' -ApiKey '<api-key>' -Title 'Example.Movie.2024.1080p'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Radarr.ParseResult]

        This function returns deserialized Radarr response objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Radarr.ParseResult')]
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

        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Title
    )

    $request = @{
        Endpoint            = 'parse'
        Method              = 'GET'
        ExpectedApplication = 'Radarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Title = 'title'
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
