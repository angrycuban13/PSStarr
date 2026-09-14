BeforeDiscovery {
    $liveEnabled = $env:PSSTARR_RUN_INTEGRATION -ceq '1'
}

Describe 'Opt-in live GET requests' -Tag Integration {
    BeforeAll {
        Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
    }

    It 'reads <Application> system status' -Skip:(-not $liveEnabled) -ForEach @(
        @{ Application = 'Radarr'; Prefix = 'PSSTARR_RADARR' }
        @{ Application = 'Sonarr'; Prefix = 'PSSTARR_SONARR' }
    ) {
        $url = [System.Environment]::GetEnvironmentVariable("${Prefix}_URL", 'Process')
        $apiKey = [System.Environment]::GetEnvironmentVariable("${Prefix}_API_KEY", 'Process')

        if ([string]::IsNullOrWhiteSpace($url) -or [string]::IsNullOrWhiteSpace($apiKey)) {
            throw "Integration testing requires ${Prefix}_URL and ${Prefix}_API_KEY."
        }

        # Suppress transport details here so live credentials cannot appear in test reports.
        try {
            $status = Get-StarrSystemStatus -Url $url -ApiKey $apiKey -ErrorAction Stop -Verbose:$false -Debug:$false
        }
        catch {
            throw "$Application integration GET failed; inspect the sanitized module log."
        }

        [string]::IsNullOrWhiteSpace($status.version) | Should -BeFalse
        $status.appName | Should -Be $Application
    }
}
