function Get-StarrTagUsage {
    <#
    .SYNOPSIS
        Retrieves resources associated with application tags.

    .DESCRIPTION
        This function reads tag usage records from the tag/detail endpoint. It reports relationships to tagged resources; use Get-StarrTag to retrieve tag definitions.

    .PARAMETER Name
        The optional saved Starr instance name. The instance is inferred when omitted.

    .PARAMETER Url
        The absolute Starr application base URL.

    .PARAMETER ApiKey
        The API key used to authenticate.

    .PARAMETER Application
        The expected application type. Specify Prowlarr with explicit credentials to use API v1.

    .PARAMETER TagId
        The positive identifier used to limit usage records to one tag.

    .EXAMPLE
        Get-StarrTagUsage -Name RadarrMain

    .EXAMPLE
        Get-StarrTagUsage -Url 'http://localhost:8989' -ApiKey '<api-key>' -TagId 3

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns tag usage response objects.
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
        $TagId
    )

    $request = @{
        Endpoint = 'tag/detail'
        Method   = 'GET'
    }

    if ($PSBoundParameters.ContainsKey('TagId')) {
        $request.Endpoint = "tag/detail/$TagId"
    }

    if ($PSBoundParameters.ContainsKey('Application')) {
        $request.ExpectedApplication = $Application
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
