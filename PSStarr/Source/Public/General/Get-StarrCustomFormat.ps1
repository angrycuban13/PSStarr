function Get-StarrCustomFormat {
    <#
    .SYNOPSIS
        Retrieves custom formats from a Starr instance.

    .DESCRIPTION
        This function retrieves custom formats from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER InstanceName
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Application
        The expected application type. This filters inferred instances and validates named or explicit targets.

    .PARAMETER CustomFormatId
        The positive CustomFormat resource identifier used for an individual lookup.

    .EXAMPLE
        Get-StarrCustomFormat

    .EXAMPLE
        Get-StarrCustomFormat -InstanceName 'Main'

    .EXAMPLE
        Get-StarrCustomFormat -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.CustomFormat]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.CustomFormat')]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Named')]
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
        $Application,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $CustomFormatId
    )

    $endpoint = 'customformat'

    $request = @{
        Endpoint = $endpoint
    }

    if ($PSBoundParameters.ContainsKey('Application')) {
        $request.ExpectedApplication = $Application
    }
    if ($PSBoundParameters.ContainsKey('CustomFormatId')) {
        $request.Endpoint = "$endpoint/$CustomFormatId"
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
