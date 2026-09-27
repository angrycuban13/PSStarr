---
title: Contributing
description: Contribute code and documentation to PSStarr.
---

<!-- markdownlint-disable MD025 -->
# Contributing
<!-- markdownlint-enable MD025-->

PSStarr accepts fixes, command additions, tests, and documentation updates through pull requests.

## Before you start

- Use PowerShell 7 or later.
- Install [Git](https://git-scm.com/).
- Install [uv](https://docs.astral.sh/uv/) to build the documentation site.
- Fork the repository and create a branch from the latest `main` branch.
- Read the repository rules in `AGENTS.md`.
- Do not include real API keys in code, tests, logs, or examples.

## Change the module

Place public functions in `PSStarr/Source/Public`. Place private functions in `PSStarr/Source/Private`.

Use one function in each script. Give each public script the same name as its function. Add Pester tests for changed behavior.

Every function must include comment-based help. Describe what the function does. Do not describe its internal implementation.

Run the complete release gate from the repository root:

```powershell
./PSStarr/tools/Test-Release.ps1
```

Changes to module source or packaging require a new manifest version and changelog entry. Prepare these changes before you open the pull request:

```powershell
./PSStarr/tools/Prepare-Release.ps1 -Version <new-version>
```

Review the manifest and changelog changes before you commit them.

## Build the documentation

The command reference comes from the comment-based help in the built module. Do not edit generated command pages directly.

Install the required PowerShell modules:

```powershell
Install-Module Configuration -RequiredVersion 1.6.0 -Scope CurrentUser
Install-Module Microsoft.PowerShell.PlatyPS -RequiredVersion 1.0.3 -Scope CurrentUser
Install-Module ModuleBuilder -RequiredVersion 3.2.18 -Scope CurrentUser
```

Build the module and generate the command reference:

```powershell
$manifest = Import-PowerShellDataFile ./PSStarr/Source/PSStarr.psd1
$version = [string]$manifest.ModuleVersion

Build-Module ./PSStarr/build.psd1

./ci/New-ModuleDocs.ps1 `
    -ModulePath "./PSStarr/Output/PSStarr/$version/PSStarr.psd1" `
    -OutputPath ./docs/command-reference
```

The generator creates an index and one page for each exported command. The root `.nav.yml` file controls the main navigation.

Synchronize the locked documentation environment:

```powershell
uv sync --locked --only-group docs
```

Start the local documentation server:

```powershell
uv run --locked --only-group docs zensical serve
```

Open `http://localhost:8000`. Check the navigation, links, examples, input types, and output types.

Run the strict site build before you commit:

```powershell
uv run --locked --only-group docs zensical build --clean --strict
```

## Open a pull request

Commit the source, tests, generated documentation, manifest, and changelog changes together. Open a pull request against `main`.

The pull request must pass release validation. Documentation changes must also pass the documentation consistency check.
