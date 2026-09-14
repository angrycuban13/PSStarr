function Get-StarrBackup {
    <#
    .SYNOPSIS
        Retrieves system backups from a Starr instance.

    .DESCRIPTION
        This function retrieves system backups from an inferred or named Starr instance, or from an explicit URL and API key.

    .PARAMETER InstanceName
        The optional name of a saved Starr instance. When omitted, the only matching instance is used.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Application
        The expected application type. Specify Prowlarr with explicit credentials to use API v1.

    .EXAMPLE
        Get-StarrBackup

    .EXAMPLE
        Get-StarrBackup -InstanceName 'Main'

    .EXAMPLE
        Get-StarrBackup -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [PSStarr.Backup]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType('PSStarr.Backup')]
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
        [ValidateSet('Radarr', 'Sonarr', 'Prowlarr')]
        [System.String]
        $Application
    )

    $endpoint = 'system/backup'

    $request = @{
        Endpoint = $endpoint
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
