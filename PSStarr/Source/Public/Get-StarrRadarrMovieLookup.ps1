function Get-StarrRadarrMovieLookup {
    <#
    .SYNOPSIS
        Get-Starr Radarr Movie Lookup.

    .DESCRIPTION
        This function retrieves Radarr Movie Lookup data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Term
        The lookup search term.

    .PARAMETER ImdbId
        The IMDb title identifier.

    .PARAMETER TmdbId
        The TMDB movie identifier.

    .EXAMPLE
        Get-StarrRadarrMovieLookup -Name 'RadarrMain' -Term 'example'

    .EXAMPLE
        Get-StarrRadarrMovieLookup -Url 'http://localhost:7878' -ApiKey '<api-key>' -Term 'example'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedTerm')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedTerm')]
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedImdb')]
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedTmdb')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTerm')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitImdb')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTmdb')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTerm')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitImdb')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTmdb')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedTerm')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTerm')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Term,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedImdb')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitImdb')]
        [ValidatePattern('^tt\d+$')]
        [string]
        $ImdbId,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedTmdb')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTmdb')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $TmdbId
    )

    $request = @{ExpectedApplication = 'Radarr' }
    $endpoint = 'movie/lookup'

    if ($PSCmdlet.ParameterSetName -like '*Imdb') {
        $request.Endpoint = "$endpoint/imdb"
        $request.Query = @{
            ImdbId = $ImdbId
        }
    }
    elseif ($PSCmdlet.ParameterSetName -like '*Tmdb') {
        $request.Endpoint = "$endpoint/tmdb"
        $request.Query = @{
            TmdbId = $TmdbId
        }
    }
    else {
        $request.Endpoint = $endpoint
        $request.Query = @{
            Term = $Term
        }
    }

    if ($PSCmdlet.ParameterSetName -like 'Named*') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





