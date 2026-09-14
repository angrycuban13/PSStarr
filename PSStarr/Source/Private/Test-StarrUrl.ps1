function Test-StarrUrl {
    <#
    .SYNOPSIS
        Validates a Starr instance URL.

    .DESCRIPTION
        This function verifies that a value is an absolute HTTP or HTTPS URL with a host.

    .PARAMETER Url
        The absolute URL to validate.

    .EXAMPLE
        Test-StarrUrl -Url 'http://localhost:7878'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Boolean]

        This function returns a Boolean indicating whether the value is valid.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Url
    )

    $uri = $null

    if (-not [uri]::TryCreate($Url, [UriKind]::Absolute, [ref] $uri)) {
        throw 'Url must be an absolute URL.'
    }

    if ($uri.Scheme -notin 'http', 'https') {
        throw 'Url must use HTTP or HTTPS.'
    }

    if ([string]::IsNullOrWhiteSpace($uri.Host)) {
        throw 'Url must include a host.'
    }

    $true
}
