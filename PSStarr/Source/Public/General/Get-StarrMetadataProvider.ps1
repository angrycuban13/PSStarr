function Get-StarrMetadataProvider {
    <#
    .SYNOPSIS
        Retrieves metadata provider settings from Radarr or Sonarr.

    .DESCRIPTION
        This function retrieves metadata provider settings using an inferred or named instance, or explicit connection credentials.

    .PARAMETER InstanceName
        The saved instance name. When omitted, the only configured instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER Application
        The expected application type. This filters inferred instances and validates named or explicit targets.

    .PARAMETER MetadataProviderId
        The positive resource identifier for an individual metadata provider.

    .EXAMPLE
        Get-StarrMetadataProvider -InstanceName 'Main'

    .EXAMPLE
        Get-StarrMetadataProvider -InstanceName 'Main' -MetadataProviderId 1

    .EXAMPLE
        Get-StarrMetadataProvider -Url 'http://localhost:8989' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized metadata provider objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
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
        $Application,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MetadataProviderId
    )

    $request = @{
        Endpoint = 'metadata'
        Method   = 'GET'
    }

    if ($PSBoundParameters.ContainsKey('Application')) {
        $request.ExpectedApplication = $Application
    }

    if ($PSBoundParameters.ContainsKey('MetadataProviderId')) {
        $request.Endpoint = "metadata/$MetadataProviderId"
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
