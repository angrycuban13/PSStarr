BeforeAll {
    Import-Module "$PSScriptRoot/../Output/PSStarr/1.0.0/PSStarr.psd1" -Force
}

Describe 'Public module configuration command names' {
    It 'exports <Verb>-PSStarrInstance without the former name' -ForEach @(
        @{ Verb = 'Get' }
        @{ Verb = 'Set' }
        @{ Verb = 'Remove' }
    ) {
        $module = Get-Module PSStarr

        $module.ExportedFunctions.ContainsKey("$Verb-PSStarrInstance") | Should -BeTrue
        $module.ExportedCommands.ContainsKey("$Verb-StarrInstance") | Should -BeFalse
    }

    It 'keeps application commands under Starr' {
        (Get-Module PSStarr).ExportedFunctions.ContainsKey('Get-StarrSystemStatus') | Should -BeTrue
    }
}
