function Get-StarrRadarrNamingExample {
    <#
    .SYNOPSIS
        Retrieves Radarr naming example results.

    .DESCRIPTION
        This function previews movie and folder naming without saving settings. With no custom parameters, Radarr uses saved naming settings. Custom previews require NamingConfigId because Radarr otherwise discards query overrides. Supply all relevant custom settings: omitted custom fields use server model defaults rather than merging with saved settings.

    .PARAMETER InstanceName
        The saved Radarr instance name. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Radarr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with Radarr.

    .PARAMETER NamingConfigId
        The positive naming configuration identifier required to activate custom previews.

    .PARAMETER RenameMovies
        Whether the custom naming configuration enables renaming.

    .PARAMETER ReplaceIllegalCharacters
        Whether custom naming replaces illegal characters.

    .PARAMETER ColonReplacementFormat
        The colon replacement style.

    .PARAMETER StandardMovieFormat
        The custom movie filename format.

    .PARAMETER MovieFolderFormat
        The custom movie folder format.

    .PARAMETER ResourceName
        The naming configuration resource name.

    .EXAMPLE
        Get-StarrRadarrNamingExample -InstanceName 'Main' -NamingConfigId 1 -StandardMovieFormat '{Movie Title} ({Release Year})' -MovieFolderFormat '{Movie Title} ({Release Year})'

    .EXAMPLE
        Get-StarrRadarrNamingExample -Url 'http://localhost:7878' -ApiKey '<api-key>'

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

        [Parameter(ParameterSetName = 'NamedCustom')]
        [Parameter(ParameterSetName = 'ExplicitCustom')]
        [System.Boolean]
        $RenameMovies,

        [Parameter(ParameterSetName = 'NamedCustom')]
        [Parameter(ParameterSetName = 'ExplicitCustom')]
        [System.Boolean]
        $ReplaceIllegalCharacters,

        [Parameter(ParameterSetName = 'NamedCustom')]
        [Parameter(ParameterSetName = 'ExplicitCustom')]
        [ValidateSet('delete', 'dash', 'spaceDash', 'spaceDashSpace', 'smart')]
        [System.String]
        $ColonReplacementFormat,

        [Parameter(ParameterSetName = 'NamedCustom')]
        [Parameter(ParameterSetName = 'ExplicitCustom')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $StandardMovieFormat,

        [Parameter(ParameterSetName = 'NamedCustom')]
        [Parameter(ParameterSetName = 'ExplicitCustom')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $MovieFolderFormat,

        [Parameter(ParameterSetName = 'NamedCustom')]
        [Parameter(ParameterSetName = 'ExplicitCustom')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ResourceName
    )

    $request = @{
        Endpoint            = 'config/naming/examples'
        Method              = 'GET'
        ExpectedApplication = 'Radarr'
    }

    $query = New-StarrApiQuery -BoundParameters $PSBoundParameters -ParameterMap @{
        NamingConfigId           = 'id'
        RenameMovies             = 'renameMovies'
        ReplaceIllegalCharacters = 'replaceIllegalCharacters'
        ColonReplacementFormat   = 'colonReplacementFormat'
        StandardMovieFormat      = 'standardMovieFormat'
        MovieFolderFormat        = 'movieFolderFormat'
        ResourceName             = 'resourceName'
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
