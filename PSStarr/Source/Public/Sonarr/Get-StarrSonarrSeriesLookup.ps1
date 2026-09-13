function Get-StarrSonarrSeriesLookup {
    <#
    .SYNOPSIS
        Searches Sonarr metadata providers for series to add.

    .DESCRIPTION
        This function searches Sonarr metadata providers by term or TVDB ID. It returns candidates and does not add series.

    .PARAMETER InstanceName
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Term
        The lookup search term.

    .EXAMPLE
        Get-StarrSonarrSeriesLookup -InstanceName 'RadarrMain' -Term 'example'

    .EXAMPLE
        Get-StarrSonarrSeriesLookup -Url 'http://localhost:7878' -ApiKey '<api-key>' -Term 'example'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Named')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Term
    )

    $request = @{
        Endpoint            = 'series/lookup'
        ExpectedApplication = 'Sonarr'
        Query               = @{
            Term = $Term
        }
    }

    if ($PSCmdlet.ParameterSetName -like 'Explicit*') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
