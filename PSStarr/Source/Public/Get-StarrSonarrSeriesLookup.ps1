function Get-StarrSonarrSeriesLookup {
    <#
    .SYNOPSIS
        Get-Starr Sonarr Series Lookup.

    .DESCRIPTION
        This function retrieves Sonarr Series Lookup data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Term
        The lookup search term.

    .EXAMPLE
        Get-StarrSonarrSeriesLookup -Name 'RadarrMain' -Term 'example'

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
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

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

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





