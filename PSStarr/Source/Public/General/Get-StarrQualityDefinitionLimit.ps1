function Get-StarrQualityDefinitionLimit {
    <#
    .SYNOPSIS
        Retrieves quality definition limits from Radarr or Sonarr.

    .DESCRIPTION
        This function retrieves quality definition limits using an inferred or named instance, or explicit connection credentials.

    .PARAMETER InstanceName
        The saved instance name. When omitted, the only configured instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER Application
        The expected application type. This filters inferred instances and validates named or explicit targets.

    .EXAMPLE
        Get-StarrQualityDefinitionLimit -InstanceName 'Main'

    .EXAMPLE
        Get-StarrQualityDefinitionLimit -Url 'http://localhost:8989' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.QualityDefinitionLimit]

        This function returns deserialized quality definition limits.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.QualityDefinitionLimit')]
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

        [Parameter(Mandatory = $false)]
        [ValidateSet('Radarr', 'Sonarr')]
        [System.String]
        $Application
    )

    $request = @{
        Endpoint = 'qualitydefinition/limits'
        Method   = 'GET'
    }

    if ($PSBoundParameters.ContainsKey('Application')) {
        $request.ExpectedApplication = $Application
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    Invoke-StarrApiRequest @request
}
