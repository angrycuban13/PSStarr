---
title: Get started
description: Install PSStarr and configure a saved application connection.
---

# Get started

## Requirements

- PowerShell 7.0 or later
- Radarr, Sonarr, or Prowlarr
- An API key for the application

## Install PSStarr

```powershell
Install-Module -Name PSStarr -Repository PSGallery
Import-Module -Name PSStarr
```

## Save a connection

This example saves a Radarr connection.

```powershell
Set-PSStarrInstance `
    -Name 'RadarrMain' `
    -Application Radarr `
    -Url 'https://radarr.example.com' `
    -ApiKey $env:RADARR_API_KEY
```

Windows encrypts the API key for the current user and host by default.
For portable encryption, set `PSSTARR_AES_KEY` to a Base64-encoded 32-byte key.

## Test the connection

```powershell
Get-StarrSystemStatus -InstanceName 'RadarrMain'
```

See the [command reference](modules/PSStarr/PSStarr.md) for all supported commands.
