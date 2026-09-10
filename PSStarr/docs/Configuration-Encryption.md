# Configuration Encryption

PSStarr encrypts only saved API keys. Instance names, application types, and URLs remain readable in the configuration file.

## Encryption modes

`Set-PSStarrInstance` accepts `-EncryptionMode None`, `Dpapi`, or `Aes256`.

- On Windows, omitting `-EncryptionMode` defaults to `Dpapi`.
- On non-Windows systems, omitting `-EncryptionMode` defaults to `None` because PowerShell does not provide equivalent native `SecureString` protection there.
- `Dpapi` is available only on Windows and binds the saved API key to the current user on the current computer.
- `Aes256` is portable but requires the same external key whenever PSStarr reads the saved instance.
- `None` stores the API key as plaintext and must be selected explicitly on Windows.

Existing plaintext configuration remains readable. Saving an existing instance again writes its API key using the newly selected or platform-default mode.

## Windows DPAPI

No encryption parameter is required on Windows:

```powershell
Set-PSStarrInstance `
    -Name RadarrMain `
    -Application Radarr `
    -Url http://localhost:7878 `
    -ApiKey '<api-key>'
```

Only the same Windows user on the same computer can decrypt the saved key. A scheduled task or service must run under that identity with its profile available. Copying only the configuration to another user or computer does not preserve access.

## Portable AES-256

Generate exactly 32 random bytes and Base64-encode them:

```powershell
$key = [System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32)
$encodedKey = [System.Convert]::ToBase64String($key)
```

Store `$encodedKey` in a password manager, CI secret, service secret, or external vault. Do not save it beside `Configuration.psd1`.

Set the key in each process that uses the saved configuration:

```powershell
$env:PSSTARR_AES_KEY = '<Base64-encoded-32-byte-key>'

Set-PSStarrInstance `
    -Name RadarrMain `
    -Application Radarr `
    -Url http://localhost:7878 `
    -ApiKey '<api-key>' `
    -EncryptionMode Aes256
```

The same environment variable must be available when endpoint commands resolve that instance. PSStarr fails rather than falling back to plaintext when the key is missing, malformed, or incorrect.

Environment variables provide key separation from the configuration file, but they remain accessible to sufficiently privileged processes and administrators. Inject the variable from an appropriate secret store instead of embedding it in scripts.

## Plaintext

Use plaintext only when its tradeoff is acceptable:

```powershell
Set-PSStarrInstance `
    -Name RadarrMain `
    -Application Radarr `
    -Url http://localhost:7878 `
    -ApiKey '<api-key>' `
    -EncryptionMode None
```

Losing the AES key or the Windows user profile needed by DPAPI makes the encrypted API key unrecoverable. Retain a protected copy of the original Starr API key or be prepared to regenerate it in the application.
