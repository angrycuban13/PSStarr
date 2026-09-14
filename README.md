<!-- omit in toc -->
# PSStarr

PSStarr is a PowerShell 7 client module for Radarr, Sonarr, and Prowlarr.

<!-- omit in toc -->
## Table of Contents

- [Installation](#installation)
- [First Time Configuration](#first-time-configuration)
  - [DPAPI](#dpapi)
  - [Plaintext](#plaintext)
  - [Portable AES-256](#portable-aes-256)
- [Usage](#usage)
  - [Reading resources](#reading-resources)
  - [Pipeline usage](#pipeline-usage)
  - [Submit commands](#submit-commands)
  - [Advanced Usage](#advanced-usage)
    - [Command submission](#command-submission)
    - [Transport](#transport)
- [Development](#development)
  - [Local Development](#local-development)
- [Changelog](#changelog)
- [License](#license)

### Features

`PSStarr` offers the following features:

- Stable typed PowerShell objects using `PSStarr.*` type names while retaining every upstream property
- Concise default views with complete output available through `Format-List *` and `Select-Object *`
- Pipeline-friendly parent-to-child resource commands
- Named connections with DPAPI or portable AES-256 API-key encryption
- Explicit URL and API-key parameters for ephemeral and CI use
- Discoverable Radarr, Sonarr, and Prowlarr endpoint wrappers with validated query parameters
- `ShouldProcess`, `-WhatIf`, and confirmation support for state-changing commands
- Credential-safe errors, configuration output, provider responses, and operational logs
- Public advanced transport and command-submission escape hatches

<!-- omit in toc -->
## Supported applications

| Application | API |
| --- | --- |
| Radarr | v3 |
| Sonarr | v3 |
| Prowlarr | v1 |

> [!NOTE]
> Lidarr, Readarr, and Whisparr are not included because they are semi-abandoned and/or deprecated.

<!-- omit in toc -->
## Requirements

- PowerShell 7.0+
- [`Configuration`](https://www.powershellgallery.com/packages/Configuration) module 1.6.0+

## Installation

Install a published release from the PowerShell Gallery:

```powershell
Install-Module -Name PSStarr -Scope CurrentUser
```

## First Time Configuration

### DPAPI

> [!TIP]
> Windows platforms default to **DPAPI**.

```powershell
$params = @{
    Name = 'Radarr'
    Application = 'Radarr'
    Url = 'http://localhost:7878'
    ApiKey = '<api-key>'
    EncryptionMode = 'Dpapi'
}

Set-PSStarrInstance @params
```

### Plaintext

> [!NOTE]
> Non-Windows platforms default to **plaintext**.
>
> Plaintext storage must be selected **explicitly** on Windows.

```powershell
$params = @{
    Name = 'RadarrPlaintext'
    Application = 'Radarr'
    Url = 'http://localhost:7878'
    ApiKey = '<api-key>'
    EncryptionMode = 'None'
}

Set-PSStarrInstance @params
```

### Portable AES-256

```powershell
$env:PSSTARR_AES_KEY = '<user-supplied-base64-encoded-32-byte-key>'
$params = @{
    Name = 'Sonarr'
    Application = 'Sonarr'
    Url = 'http://localhost:8989'
    ApiKey = '<api-key>'
    EncryptionMode = 'Aes256'
}

Set-PSStarrInstance @params
```

## Usage

### Reading resources

```powershell
$movie = Get-StarrRadarrMovie -InstanceName Radarr -MovieId 42
$series = Get-StarrSonarrSeries -InstanceName Sonarr -SeriesId 7
```

### Pipeline usage

```powershell
$series | Get-StarrSonarrEpisode
$movie | Get-StarrRadarrMovieFile
```

### Submit commands

> [!WARNING]
> Search and release endpoints can consume quotas.

```powershell
Start-StarrRadarrMovieRefresh -InstanceName Radarr -MovieId 42
Start-StarrSonarrEpisodeSearch -InstanceName Sonarr -EpisodeId 101
```

>[!TIP]
> State-changing commands support `-WhatIf` and confirmation.

### Advanced Usage

#### Command submission

```powershell
Invoke-StarrCommand -InstanceName Radarr -CommandName RefreshMovie -Arguments @{ movieIds = @(42) }
```

#### Transport

```powershell
Invoke-StarrApiRequest -InstanceName Radarr -Method GET -Endpoint 'movie/42'
```

> [!NOTE]
> `Invoke-StarrApiRequest` remains a public function for not yet implemented endpoints.
>
> Callers are responsible for selecting the endpoint, and response handling.

## Development

Run the complete release gate from the repository root:

```powershell
./PSStarr/tools/Test-Release.ps1
```

Live tests are opt-in and require local instance configuration. Unit tests use mocked HTTP and fake credentials.

### Local Development

For local development, build and import the module:

```powershell
Install-Module -Name ModuleBuilder -Scope CurrentUser

Set-Location ./PSStarr

Import-Module ModuleBuilder

Build-Module ./build.psd1

Import-Module ./Output/PSStarr/1.0.0/PSStarr.psd1 -Force
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

PSStarr is licensed under the [MIT License](LICENSE).
