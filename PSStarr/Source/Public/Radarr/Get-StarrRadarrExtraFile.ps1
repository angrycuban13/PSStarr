function Get-StarrRadarrExtraFile {
    <#
    .SYNOPSIS
        Retrieves Radarr extra-file records.

    .DESCRIPTION
        This function retrieves Radarr extra-file records through the shared transport. It returns file information, not file contents.

    .PARAMETER Name
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER MovieId
        The positive Radarr movie identifier used to filter records.

    .EXAMPLE
        Get-StarrRadarrExtraFile -Name 'Main' -MovieId 42

    .EXAMPLE
        Get-StarrRadarrExtraFile -Url 'http://localhost:7878' -ApiKey '<api-key>' -MovieId 42

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized extra-file records.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedList')]
    [OutputType([System.Object])]
    param(
        [Parameter(ParameterSetName = 'NamedList')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitList')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitList')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(ParameterSetName = 'NamedList')]
        [Parameter(ParameterSetName = 'ExplicitList')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId
    )

    $request = @{
        Endpoint            = 'extrafile'
        Method              = 'GET'
        ExpectedApplication = 'Radarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        MovieId = 'movieId'
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
