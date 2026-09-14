function Unprotect-StarrConfigurationSecret {
    <#
    .SYNOPSIS
        Resolves a persisted PSStarr configuration secret.

    .DESCRIPTION
        This function returns legacy plaintext secrets and decrypts supported versioned DPAPI or AES-256 secret envelopes.

    .PARAMETER Value
        The persisted plaintext value or encrypted secret envelope.

    .EXAMPLE
        Unprotect-StarrConfigurationSecret -Value 'legacy-value'

    .EXAMPLE
        Unprotect-StarrConfigurationSecret -Value $encryptedValue

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.String]

        This function returns the decrypted secret as plaintext.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Value
    )

    if ($Value -is [System.String]) {
        return $Value
    }

    if ($Value -isnot [System.Collections.IDictionary]) {
        throw 'The saved Starr API key has an invalid format.'
    }

    if ($Value.Version -ne 1) {
        throw "The saved Starr API key uses unsupported encryption version '$($Value.Version)'."
    }

    if ([System.String]::IsNullOrWhiteSpace([System.String] $Value.CipherText)) {
        throw 'The saved Starr API key does not contain ciphertext.'
    }

    try {
        switch ($Value.Mode) {
            'Dpapi' {
                if (-not $IsWindows) {
                    throw 'DPAPI configuration encryption is supported only on Windows.'
                }

                $secureSecret = ConvertTo-SecureString -String $Value.CipherText -ErrorAction Stop
            }
            'Aes256' {
                $key = Get-StarrAesKey
                $secureSecret = ConvertTo-SecureString -String $Value.CipherText -Key $key -ErrorAction Stop
            }
            default {
                throw "The saved Starr API key uses unsupported encryption mode '$($Value.Mode)'."
            }
        }

        $secretPointer = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureSecret)

        try {
            [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($secretPointer)
        }
        finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($secretPointer)
        }
    }
    catch {
        throw [System.Security.Cryptography.CryptographicException]::new('Unable to decrypt a saved Starr API key. Verify the encryption mode, user context, and AES key.', $_.Exception)
    }
}
