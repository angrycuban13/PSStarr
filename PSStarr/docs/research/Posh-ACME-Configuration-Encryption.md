# Posh-ACME Configuration Encryption Research

Research date: 2026-09-07
Posh-ACME revision: [`41a313732d7d43f48c4803b105de6b2b379210fc`](https://github.com/rmbolger/Posh-ACME/tree/41a313732d7d43f48c4803b105de6b2b379210fc) (repository `master` at inspection time)

## Executive Summary

Posh-ACME does not encrypt its complete configuration. It encrypts only values represented as `SecureString` or the password portion of `PSCredential` objects in plugin arguments. Ordinary plugin values and the remainder of its account/order configuration remain plaintext.

It delegates both supported encryption modes to PowerShell's `ConvertFrom-SecureString` and `ConvertTo-SecureString` cmdlets:

- With no `-Key`, Windows PowerShell/PowerShell uses Windows DPAPI. The encrypted value is bound to the Windows user and machine context.
- With a 32-byte `-Key`, PowerShell uses AES with a 256-bit key. This is portable wherever the same key is available.

That structure is reusable for PSStarr, but copying Posh-ACME's default AES key storage would weaken the security claim: Posh-ACME normally stores the AES key in the same configuration tree as the ciphertext. Its own documentation notes that anyone who can read those files can decrypt the protected values. PSStarr should not call that arrangement secure encryption against a configuration-directory reader.

## What Posh-ACME Encrypts

`Export-PluginArgs` recursively walks plugin arguments. A `SecureString` becomes a JSON object containing `origType: "securestring"` and an encrypted `value`. A `PSCredential` becomes `origType: "pscredential"`, a plaintext `user`, and an encrypted `pass`. Arrays are traversed recursively, while every other value is returned unchanged. The resulting object is written to `pluginargs.json`. See [`SecureSerialize`](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Private/Export-PluginArgs.ps1#L30-L56) and the [file write](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Private/Export-PluginArgs.ps1#L120-L134).

`Get-PAPluginArgs` reverses those type-tagged JSON objects with the same encryption parameters. Decryption failure is isolated to the affected plugin argument and produces a warning. See [`SecureDeserialize`](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Public/Get-PAPluginArgs.ps1#L15-L55) and the [JSON import/decryption loop](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Public/Get-PAPluginArgs.ps1#L81-L105).

This is field-level encryption, not whole-file encryption. For PSStarr, the analogous sensitive field is currently each instance's `ApiKey`; `Name`, `Application`, and `Url` need not be encrypted.

## Mode Selection and Platform Defaults

The account's `sskey` property is the mode marker:

| `sskey` value | Parameters splatted to SecureString cmdlets | Effective mode |
| --- | --- | --- |
| Null or empty | Empty hashtable | PowerShell default: DPAPI on Windows; no encrypted-at-rest protection on non-Windows |
| Base64Url key | `Key = <decoded bytes>` | AES, normally AES-256 |
| Literal `VAULT` | Key retrieved from SecretManagement, decoded, then `Key = <bytes>` | AES, with the key stored outside the config |

The exact branching is in [`Get-EncryptionParam`](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Private/Get-EncryptionParam.ps1#L9-L63). Microsoft documents that `ConvertFrom-SecureString -Key` uses AES and accepts 128-, 192-, or 256-bit keys; without a key it uses Windows DPAPI. Microsoft also states that `SecureString` contents are not encrypted on non-Windows systems. See [`ConvertFrom-SecureString`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertfrom-securestring?view=powershell-7.6).

Posh-ACME describes the practical consequence directly: the Windows default is restricted to the current user on the current computer, portable AES avoids that restriction, and non-Windows users must enable alternative encryption to obtain encrypted-at-rest plugin secrets. See its [FAQ encryption section](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/docs/FAQ/index.md#L67-L94) and [alternate-config warning](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/docs/Guides/Using-an-Alternate-Config-Location.md#L20-L30).

DPAPI is Windows-only and protects data with user or machine credentials. The PowerShell default here is user-scoped. A process running under another identity, or under impersonation without that user's profile loaded, can be unable to decrypt it. See Microsoft's [`ProtectedData` documentation](https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.protecteddata?view=net-11.0-pp).

## AES Key Generation and Storage

`New-AesKey` accepts 128, 192, or 256 bits and defaults to 256. It allocates `BitLength / 8` bytes, fills them with `RNGCryptoServiceProvider`, and returns Base64Url text. There is no password and no key-derivation function. See [`New-AesKey`](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Private/New-AesKey.ps1#L1-L20).

For new PowerShell 7 code, `RandomNumberGenerator.Fill()` or `RandomNumberGenerator.GetBytes()` is the clearer current .NET API; `RNGCryptoServiceProvider` is obsolete. The important design property is 32 cryptographically random bytes, not the older provider class.

By default, Posh-ACME stores the Base64Url AES key directly in `acct.json` as `sskey`. When SecretManagement is configured, it instead writes `sskey: "VAULT"`, records a `VaultGuid`, and stores the key under `poshacme-{VaultGuid}-sskey` or a configured name template. See [`Set-AltPluginEncryption`](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Private/Set-AltPluginEncryption.ps1#L43-L111) and the [SecretManagement guide](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/docs/Guides/Using-SecretManagement.md#L1-L64).

If vault storage fails, Posh-ACME warns and falls back to placing the key in the account object. That availability-first fallback is dangerous for PSStarr because a user can believe a requested external-key mode succeeded when it silently lost its security boundary. PSStarr should fail the configuration write instead.

## Ciphertext File Format

Posh-ACME owns only the outer JSON shape. The encrypted string itself is PowerShell's `ConvertFrom-SecureString` serialization format; Posh-ACME does not implement an IV, cipher mode, padding scheme, authentication tag, or format version itself. Therefore, claims about those internals should follow the supported PowerShell contract—DPAPI without `-Key`, AES with `-Key`—rather than treating PowerShell's current internal serialization as Posh-ACME's stable format.

Example conceptual `pluginargs.json` shape:

```json
{
  "ApiToken": {
    "origType": "securestring",
    "value": "<ConvertFrom-SecureString output>"
  },
  "Credential": {
    "origType": "pscredential",
    "user": "example-user",
    "pass": "<ConvertFrom-SecureString output>"
  },
  "OrdinaryValue": "plaintext"
}
```

The same key must be supplied to `ConvertTo-SecureString` to reverse an AES-protected value. See Microsoft's [`ConvertTo-SecureString`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertto-securestring?view=powershell-7.6).

## Public Controls and Migration

Posh-ACME exposes:

- `New-PAAccount -UseAltPluginEncryption`
- `Set-PAAccount -UseAltPluginEncryption`
- `Set-PAAccount -UseAltPluginEncryption:$false`
- `Set-PAAccount -ResetAltPluginEncryption`

See [`New-PAAccount`](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Public/New-PAAccount.ps1#L218-L220) and [`Set-PAAccount`](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Public/Set-PAAccount.ps1#L106-L114).

Changing or resetting the mode is a migration, not merely a metadata update. Posh-ACME first decrypts every existing order's plugin arguments with the old mode, changes the key marker, saves the account, then re-exports all plugin arguments under the new mode. See [`Set-AltPluginEncryption`](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Private/Set-AltPluginEncryption.ps1#L28-L42) and its [rewrite phase](https://github.com/rmbolger/Posh-ACME/blob/41a313732d7d43f48c4803b105de6b2b379210fc/Posh-ACME/Private/Set-AltPluginEncryption.ps1#L113-L131).

Alternative encryption was introduced in Posh-ACME 4.0.0 by [commit `afaef019`](https://github.com/rmbolger/Posh-ACME/commit/afaef019b7776e977725aef2bc58b22a00939656). SecretManagement support followed in [commit `5fd47aa6`](https://github.com/rmbolger/Posh-ACME/commit/5fd47aa6268b4cc543ce3716e4378c74afdcb0f9).

## Recommended PSStarr Design

### User-visible modes

Use an explicit mode rather than interacting switches:

| Mode | Windows default | Non-Windows default | Meaning |
| --- | --- | --- | --- |
| `None` | No | Recommended until a portable key is supplied | Store API keys as plaintext |
| `Dpapi` | Yes | Unsupported | Encrypt API keys for the current Windows user/machine context |
| `Aes256` | Only when explicitly selected | Only when explicitly selected with a key source | Encrypt API keys with a portable 32-byte key |

The requested Windows behavior maps cleanly to `-EncryptionMode Dpapi` as the default and `-EncryptionMode Aes256` as the explicit override. A boolean such as `-UseAltEncryption` copies Posh-ACME more literally but becomes awkward once `None`, external key storage, rotation, and future modes exist.

The non-Windows default requires an explicit product decision. Silently using no key reproduces Posh-ACME's plaintext behavior. A safer contract is `None` with a clear warning, because AES cannot be secure or recoverable until the caller supplies or configures a key source. Do not silently generate and colocate a key while describing the result as protection from file readers.

### Configuration envelope

Keep the existing configuration schema but replace only `ApiKey` values with a self-describing envelope, for example:

```powershell
ApiKey = @{
    Version = 1
    Mode = 'Dpapi'
    CipherText = '<encoded data>'
}
```

AES should additionally identify its external key without storing the key:

```powershell
ApiKey = @{
    Version = 1
    Mode = 'Aes256'
    KeyId = '<stable key identifier>'
    CipherText = '<encoded data>'
}
```

This distinguishes legacy plaintext values, supports migration, rejects unknown versions/modes clearly, and avoids guessing based on ciphertext prefixes.

### Key sources

Prefer these AES key sources, in order:

1. An explicit 32-byte key supplied for ephemeral/CI use without persistence.
2. Microsoft.PowerShell.SecretManagement with a configured vault.
3. A separately stored key file with restrictive permissions, documented as platform-dependent operational security.

Do not persist the AES key beside the configuration by default. If a compatibility option intentionally does so, label it as obfuscation/casual-disclosure protection rather than protection against a reader of the configuration directory.

### Required behavior

1. Encrypt before `Export-Configuration`; decrypt only inside `Get-StarrConfiguration` or a narrower private resolver before transport use.
2. Keep public display masking unchanged; encryption at rest does not authorize exposing decrypted API keys.
3. Treat mode changes and key rotation transactionally: decrypt all values first, prepare all replacements, write once, and leave the original file intact on any failure.
4. Fail closed when a requested AES key source is missing or unavailable. Never fall back from external key storage to a colocated key or plaintext.
5. Preserve explicit `-Url` and `-ApiKey` calls as ephemeral paths that do not touch persisted configuration.
6. Add tests for Windows DPAPI round trips, wrong-user/unavailable-profile errors where practical, AES round trips, wrong/missing keys, legacy plaintext migration, mode changes, rotation, corrupt envelopes, no secret leakage in errors, and non-Windows defaults.

## Security Tradeoffs

| Choice | Benefit | Limitation |
| --- | --- | --- |
| DPAPI/current user | No separate key management; strong fit for a single Windows user | Not portable across users or machines; scheduled/impersonated contexts can fail if the intended profile is unavailable |
| AES-256 with external key | Portable across OSes/users; useful for CI and shared config | Security and recoverability depend entirely on separate key custody |
| AES-256 with colocated key | Portable and hides secrets from casual viewing | Anyone who reads the directory obtains ciphertext and key; not a meaningful boundary against that attacker |
| Plaintext | Simple and portable | No confidentiality at rest |
| PowerShell SecureString serialization | Minimal code; established PowerShell behavior | Opaque PowerShell-owned format; PSStarr does not control versioning or authenticate a custom envelope |
| PSStarr-owned AES-GCM envelope | Explicit versioning and authenticated encryption | More cryptographic code, compatibility responsibility, nonce management, and test burden |

For the first implementation, using PowerShell's SecureString cmdlets mirrors Posh-ACME and keeps the code small. If PSStarr needs an independently specified, authenticated, long-lived ciphertext format, use a versioned AES-GCM envelope instead of relying on PowerShell's opaque serialization.

## Repository Fit

PSStarr currently persists `Name`, `Application`, `Url`, and plaintext `ApiKey` through the PoshCode `Configuration` module. Encryption should remain a thin private boundary around sensitive field serialization rather than replacing `Configuration` or leaking encryption concerns into every endpoint wrapper.

Suggested private seams:

- `Protect-StarrConfigurationSecret`
- `Unprotect-StarrConfigurationSecret`
- `Resolve-StarrEncryptionMode`
- an AES key-source resolver if AES support is included in the first change

Suggested public surface:

- add `-EncryptionMode <None|Dpapi|Aes256>` to `Set-StarrInstance`, with dynamic/default resolution of `Dpapi` on Windows;
- add an explicit key/key-source parameter set for `Aes256`;
- add a separate state-changing migration/rotation command if configuration-wide mode changes are required, rather than overloading a single instance write with partial migration semantics.

This preserves `Invoke-StarrApiRequest` as the only HTTP boundary and confines secret handling to configuration persistence and resolution.
