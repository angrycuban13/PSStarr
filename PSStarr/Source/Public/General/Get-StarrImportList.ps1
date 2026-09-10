function Get-StarrImportList {
    <#
    .SYNOPSIS
        Retrieves import list settings from Radarr or Sonarr.

    .DESCRIPTION
        This function retrieves import list settings using an inferred or named instance, or explicit connection credentials.

    .PARAMETER Name
        The saved instance name. When omitted, the only configured instance is used.

    .PARAMETER Url
        The absolute base URL of the instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the instance.

    .PARAMETER ImportListId
        The positive resource identifier for an individual import list.

    .EXAMPLE
        Get-StarrImportList -Name 'Main'

    .EXAMPLE
        Get-StarrImportList -Name 'Main' -ImportListId 1

    .EXAMPLE
        Get-StarrImportList -Url 'http://localhost:8989' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns deserialized import list objects.
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

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $ImportListId
    )

    $request = @{
        Endpoint = 'importlist'
        Method   = 'GET'
    }

    if ($PSBoundParameters.ContainsKey('ImportListId')) {
        $request.Endpoint = "importlist/$ImportListId"
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
