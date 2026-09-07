function Protect-StarrConfigurationSecret {
    <#
    .SYNOPSIS
        Protects a secret for persistent PSStarr configuration.

    .DESCRIPTION
        This function returns plaintext or a versioned DPAPI or AES-256 encrypted envelope for a configuration secret.

    .PARAMETER Secret
        The plaintext secret to protect.

    .PARAMETER EncryptionMode
        The encryption mode used to protect the secret.

    .EXAMPLE
        Protect-StarrConfigurationSecret -Secret 'value' -EncryptionMode Dpapi

    .EXAMPLE
        Protect-StarrConfigurationSecret -Secret 'value' -EncryptionMode None

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.String]

        This function returns the plaintext secret when encryption is disabled.

        [System.Collections.Specialized.OrderedDictionary]

        This function returns encrypted secret metadata and ciphertext when encryption is enabled.
    #>
    [CmdletBinding()]
    [OutputType([System.String], [System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Secret,

        [Parameter(Mandatory = $true)]
        [ValidateSet('None', 'Dpapi', 'Aes256')]
        [System.String]
        $EncryptionMode
    )

    if ($EncryptionMode -eq 'None') {
        return $Secret
    }

    $secureSecret = [System.Security.SecureString]::new()

    foreach ($character in $Secret.ToCharArray()) {
        $secureSecret.AppendChar($character)
    }

    $secureSecret.MakeReadOnly()

    if ($EncryptionMode -eq 'Dpapi') {
        if (-not $IsWindows) {
            throw 'DPAPI configuration encryption is supported only on Windows.'
        }

        $cipherText = ConvertFrom-SecureString -SecureString $secureSecret -ErrorAction Stop
    }
    else {
        $key = Get-StarrAesKey
        $cipherText = ConvertFrom-SecureString -SecureString $secureSecret -Key $key -ErrorAction Stop
    }

    [ordered]@{
        Version    = 1
        Mode       = $EncryptionMode
        CipherText = $cipherText
    }
}
