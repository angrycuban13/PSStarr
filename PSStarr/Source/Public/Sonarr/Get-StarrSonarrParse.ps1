function Get-StarrSonarrParse {
    <#
    .SYNOPSIS
        Retrieves Sonarr parsed release information.

    .DESCRIPTION
        This function asks Sonarr to parse a release title. When Path is supplied, Sonarr parses the path instead, but still requires Title. No import or download is performed.

    .PARAMETER Name
        The optional saved instance name. When omitted, the matching instance is inferred.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER Title
        The Title value sent to Sonarr.

    .PARAMETER Path
        The Path value sent to Sonarr.

    .EXAMPLE
        Get-StarrSonarrParse -Name Main -Title 'Example.Show.S01E01.1080p'

    .EXAMPLE
        Get-StarrSonarrParse -Url 'http://localhost:8989' -ApiKey '<api-key>' -Title 'Example.Show.S01E01.1080p'

    .EXAMPLE
        Get-StarrSonarrParse -Name Main -Title 'Example.Show.S01E01' -Path '/media/Example.Show.S01E01.mkv'

        Parses a server path while retaining the required title in the response.

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Sonarr API.
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Title,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Path
    )

    $request = @{
        Endpoint = "parse"
        Method = 'GET'
        ExpectedApplication = 'Sonarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        Title = 'title'
        Path = 'path'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
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
