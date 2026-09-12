function Get-StarrCustomFilter {
    <#
    .SYNOPSIS
        Retrieves custom filter settings from Radarr or Sonarr.

    .DESCRIPTION
        This function retrieves custom filter settings using an inferred or named instance, or explicit connection credentials.

    .PARAMETER Name
        The saved instance name. When omitted, the only configured instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER Application
        The expected application type. Specify Prowlarr with explicit credentials to use API v1.

    .PARAMETER CustomFilterId
        The positive resource identifier for an individual custom filter.

    .EXAMPLE
        Get-StarrCustomFilter -Name 'Main'

    .EXAMPLE
        Get-StarrCustomFilter -Name 'Main' -CustomFilterId 1

    .EXAMPLE
        Get-StarrCustomFilter -Url 'http://localhost:8989' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized custom filter objects.
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

        [Parameter(Mandatory = $false)]
        [ValidateSet('Radarr', 'Sonarr', 'Prowlarr')]
        [System.String]
        $Application,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $CustomFilterId
    )

    $request = @{
        Endpoint = 'customfilter'
        Method   = 'GET'
    }

    if ($PSBoundParameters.ContainsKey('Application')) {
        $request.ExpectedApplication = $Application
    }

    if ($PSBoundParameters.ContainsKey('CustomFilterId')) {
        $request.Endpoint = "customfilter/$CustomFilterId"
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
