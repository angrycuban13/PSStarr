function Get-StarrRemotePathMapping {
    <#
    .SYNOPSIS
        Retrieves remote-path mappings from a Starr instance.

    .DESCRIPTION
        This function retrieves remote-path mappings from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER InstanceName
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Application
        The expected application type. This filters inferred instances and validates named or explicit targets.

    .PARAMETER RemotePathMappingId
        The positive RemotePathMapping resource identifier used for an individual lookup.

    .EXAMPLE
        Get-StarrRemotePathMapping

    .EXAMPLE
        Get-StarrRemotePathMapping -InstanceName 'Main'

    .EXAMPLE
        Get-StarrRemotePathMapping -Url 'http://localhost:7878' -ApiKey '<api-key>'

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
        $RemotePathMappingId
    )

    $endpoint = 'remotepathmapping'

    $request = @{
        Endpoint            = $endpoint
        ExpectedApplication = @('Radarr', 'Sonarr')
    }

    if ($PSBoundParameters.ContainsKey('Application')) {
        $request.ExpectedApplication = $Application
    }
    if ($PSBoundParameters.ContainsKey('RemotePathMappingId')) {
        $request.Endpoint = "$endpoint/$RemotePathMappingId"
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
