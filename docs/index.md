---
title: Home
description: Install PSStarr and configure a saved application connection
---

<!-- markdownlint-disable MD025-->
# PSStarr
<!-- markdownlint-enable MD025-->

PSStarr is a PowerShell 7 client module for Radarr, Sonarr, and Prowlarr.

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
Set-PSStarrInstance -Name 'RadarrMain' -Application Radarr -Url 'https://radarr.example.com' -ApiKey (Read-Host -Prompt 'Enter your Radarr API key')
```

<!-- markdownlint-disable MD046-->
!!! NOTE
    By default, Windows encrypts the API key for the current user and host with DPAPI.

    For portable encryption, set `PSSTARR_AES_KEY` to a Base64-encoded 32-byte key.
<!-- markdownlint-enable MD046-->

## Test the connection

```powershell
Get-StarrSystemStatus -InstanceName 'RadarrMain'
```

See the [command reference](command-reference/index.md) for all supported commands.
