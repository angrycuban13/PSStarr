function Resolve-StarrEncryptionMode {
    <#
    .SYNOPSIS
        Resolves the configuration encryption mode for the current platform.

    .DESCRIPTION
        This function resolves an explicit encryption mode or selects DPAPI on Windows and plaintext storage on other platforms.

    .PARAMETER EncryptionMode
        The requested configuration encryption mode.

    .EXAMPLE
        Resolve-StarrEncryptionMode

    .EXAMPLE
        Resolve-StarrEncryptionMode -EncryptionMode Aes256

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.String]

        This function returns the resolved encryption mode name.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('None', 'Dpapi', 'Aes256')]
        [System.String]
        $EncryptionMode
    )

    if ($PSBoundParameters.ContainsKey('EncryptionMode')) {
        if ($EncryptionMode -eq 'Dpapi' -and -not $IsWindows) {
            throw 'DPAPI configuration encryption is supported only on Windows.'
        }

        return $EncryptionMode
    }

    if ($IsWindows) {
        return 'Dpapi'
    }

    'None'
}
