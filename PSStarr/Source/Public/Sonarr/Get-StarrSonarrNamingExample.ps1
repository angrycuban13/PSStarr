function Get-StarrSonarrNamingExample {
    <#
    .SYNOPSIS
        Retrieves Sonarr filename examples.

    .DESCRIPTION
        This function retrieves filename examples using saved Sonarr naming settings or a supplied configuration. Custom fields require NamingConfigId greater than zero; otherwise Sonarr ignores them. Custom configuration is not merged with saved settings. This function does not save settings or rename files.

    .PARAMETER InstanceName
        The optional saved instance name. When omitted, the matching instance is inferred.

    .PARAMETER Url
        The absolute Sonarr base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER NamingConfigId
        A positive configuration identifier that tells Sonarr to use supplied fields instead of saved settings. Supply the complete desired configuration; fields are not merged with saved settings.

    .PARAMETER RenameEpisodes
        Whether episode renaming is enabled in the preview.

    .PARAMETER ReplaceIllegalCharacters
        Whether illegal filename characters are replaced.

    .PARAMETER ColonReplacementFormat
        The colon replacement mode accepted by Sonarr.

    .PARAMETER CustomColonReplacementFormat
        The custom colon replacement text.

    .PARAMETER MultiEpisodeStyle
        The Sonarr multi-episode naming style, from zero through five.

    .PARAMETER StandardEpisodeFormat
        The StandardEpisodeFormat template used in the preview.

    .PARAMETER DailyEpisodeFormat
        The DailyEpisodeFormat template used in the preview.

    .PARAMETER AnimeEpisodeFormat
        The AnimeEpisodeFormat template used in the preview.

    .PARAMETER SeriesFolderFormat
        The SeriesFolderFormat template used in the preview.

    .PARAMETER SeasonFolderFormat
        The SeasonFolderFormat template used in the preview.

    .PARAMETER SpecialsFolderFormat
        The SpecialsFolderFormat template used in the preview.

    .EXAMPLE
        Get-StarrSonarrNamingExample -InstanceName Main

    .EXAMPLE
        Get-StarrSonarrNamingExample -Url 'http://localhost:8989' -ApiKey '<api-key>'

    .EXAMPLE
        Get-StarrSonarrNamingExample -InstanceName Main -NamingConfigId 1 -RenameEpisodes $true -ReplaceIllegalCharacters $true -ColonReplacementFormat 0 -MultiEpisodeStyle 0 -StandardEpisodeFormat '{Series Title} - S{season:00}E{episode:00}' -DailyEpisodeFormat '{Series Title} - {Air-Date}' -AnimeEpisodeFormat '{Series Title} - S{season:00}E{episode:00}' -SeriesFolderFormat '{Series Title}' -SeasonFolderFormat 'Season {season:00}' -SpecialsFolderFormat 'Specials'

        Previews a supplied configuration without saving it. Sonarr uses its model defaults for omitted fields, not the saved configuration.

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Sonarr.ApplicationConfiguration]

        This function returns response objects retrieved from the Sonarr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Sonarr.ApplicationConfiguration')]
    param(
        [Parameter(ParameterSetName = 'Named')]
        [Parameter(ParameterSetName = 'NamedCustom')]
        [Alias('Name')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitCustom')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitCustom')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitCustom')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $NamingConfigId,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [System.Boolean]
        $RenameEpisodes,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [System.Boolean]
        $ReplaceIllegalCharacters,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [ValidateRange(0, [System.Int32]::MaxValue)]
        [System.Int32]
        $ColonReplacementFormat,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [AllowEmptyString()]
        [System.String]
        $CustomColonReplacementFormat,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [ValidateRange(0, 5)]
        [System.Int32]
        $MultiEpisodeStyle,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [AllowEmptyString()]
        [System.String]
        $StandardEpisodeFormat,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [AllowEmptyString()]
        [System.String]
        $DailyEpisodeFormat,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [AllowEmptyString()]
        [System.String]
        $AnimeEpisodeFormat,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [AllowEmptyString()]
        [System.String]
        $SeriesFolderFormat,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [AllowEmptyString()]
        [System.String]
        $SeasonFolderFormat,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ExplicitCustom')]
        [AllowEmptyString()]
        [System.String]
        $SpecialsFolderFormat
    )

    $request = @{
        Endpoint            = 'config/naming/examples'
        Method              = 'GET'
        ExpectedApplication = 'Sonarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        NamingConfigId               = 'id'
        RenameEpisodes               = 'renameEpisodes'
        ReplaceIllegalCharacters     = 'replaceIllegalCharacters'
        ColonReplacementFormat       = 'colonReplacementFormat'
        CustomColonReplacementFormat = 'customColonReplacementFormat'
        MultiEpisodeStyle            = 'multiEpisodeStyle'
        StandardEpisodeFormat        = 'standardEpisodeFormat'
        DailyEpisodeFormat           = 'dailyEpisodeFormat'
        AnimeEpisodeFormat           = 'animeEpisodeFormat'
        SeriesFolderFormat           = 'seriesFolderFormat'
        SeasonFolderFormat           = 'seasonFolderFormat'
        SpecialsFolderFormat         = 'specialsFolderFormat'
    }

    if ($query.Count -gt 0) {
        $request.Query = $query
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
