function Write-StarrLogEntry {
    <#
    .SYNOPSIS
        Writes readable entries to the PSStarr log.

    .DESCRIPTION
        This function writes readable plain-text entries to the cross-platform PSStarr log.

    .PARAMETER Message
        The text written to the log.

    .PARAMETER LogFileDirectory
        The directory containing the PSStarr log file.

    .PARAMETER LogFileName
        The log filename.

    .PARAMETER Severity
        The severity label written with the log entry.

    .PARAMETER MaxLogsToKeep
        The maximum number of rotated log files retained.

    .PARAMETER MaxLogSizeInMB
        The log size threshold that triggers rotation.

    .PARAMETER RetryCount
        The number of additional attempts after an I/O write failure.

    .PARAMETER RetryDelayMs
        The delay in milliseconds between write attempts.

    .PARAMETER NoConsoleOutput
        Suppresses optional console output.

    .EXAMPLE
        Write-StarrLogEntry -Message 'Request completed.' -Severity Info -NoConsoleOutput

    .INPUTS
        [System.String]

        You can pipe System.String objects to this function.

    .OUTPUTS
        None.

        This function does not return objects to the pipeline.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Write-Host is used intentionally for optional colored console output.')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogFileDirectory,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogFileName = 'PSStarr.log',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]
        $Severity = 'Info',

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 100)]
        [int]
        $MaxLogsToKeep = 5,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 1000)]
        [int]
        $MaxLogSizeInMB = 5,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 10)]
        [int]
        $RetryCount = 3,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 5000)]
        [int]
        $RetryDelayMs = 200,

        [Parameter(Mandatory = $false)]
        [switch]
        $NoConsoleOutput
    )

    begin {
        $collectedMessages = [System.Collections.Generic.List[string]]::new()

        if (-not $PSBoundParameters.ContainsKey('LogFileDirectory')) {
            $LogFileDirectory = if ($IsWindows) {
                Join-Path -Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)) -ChildPath 'powershell/Logs/PSStarr'
            }
            elseif ($IsMacOS) {
                Join-Path -Path $HOME -ChildPath 'Library/Logs/PSStarr'
            }
            elseif ($IsLinux) {
                $stateHome = if (-not [string]::IsNullOrWhiteSpace($env:XDG_STATE_HOME)) {
                    $env:XDG_STATE_HOME
                }
                else {
                    Join-Path -Path $HOME -ChildPath '.local/state'
                }

                Join-Path -Path $stateHome -ChildPath 'log/PSStarr'
            }
            else {
                Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath 'Logs/PSStarr'
            }
        }

        $logFullPath = Join-Path -Path $LogFileDirectory -ChildPath $LogFileName
        $logBaseName = [IO.Path]::GetFileNameWithoutExtension($LogFileName)
    }

    process {
        $collectedMessages.Add($Message)
    }

    end {
        if ($collectedMessages.Count -eq 0) {
            return
        }

        if (-not (Test-Path -LiteralPath $LogFileDirectory -PathType Container)) {
            try {
                [void] (New-Item -Path $LogFileDirectory -ItemType Directory -Force -ErrorAction Stop)
            }
            catch {
                Write-Warning "Cannot create log directory '$LogFileDirectory'. Falling back to the temporary directory."

                $LogFileDirectory = Join-Path ([IO.Path]::GetTempPath()) "PSStarrLogs_$logBaseName"
                $logFullPath = Join-Path -Path $LogFileDirectory -ChildPath $LogFileName

                try {
                    [void] (New-Item -Path $LogFileDirectory -ItemType Directory -Force -ErrorAction Stop)
                }
                catch {
                    Write-Warning "Cannot create fallback log directory '$LogFileDirectory'. File logging was skipped."
                    return
                }
            }
        }

        if (Test-Path -LiteralPath $logFullPath -PathType Leaf) {
            try {
                $logItem = Get-Item -LiteralPath $logFullPath -ErrorAction Stop

                if ($logItem.Length -ge ($MaxLogSizeInMB * 1MB)) {
                    $archivePath = Join-Path $LogFileDirectory "${logBaseName}_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

                    Move-Item -LiteralPath $logFullPath -Destination $archivePath -Force -ErrorAction Stop

                    Get-ChildItem -Path $LogFileDirectory -Filter "${logBaseName}_*.log" -ErrorAction SilentlyContinue | Sort-Object -Property LastWriteTime -Descending | Select-Object -Skip $MaxLogsToKeep | ForEach-Object {
                        try {
                            Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
                        }
                        catch {
                            Write-Warning "Failed to remove old log archive '$($_.FullName)'."
                        }
                    }
                }
            }
            catch {
                Write-Warning "Log rotation failed: $($_.Exception.Message)"
            }
        }

        $now = [datetime]::Now
        $isNewFile = -not (Test-Path -LiteralPath $logFullPath -PathType Leaf)
        $allLines = [System.Collections.Generic.List[string]]::new()

        if ($isNewFile) {
            $divider = '=' * 80
            $allLines.Add($divider)
            $allLines.Add("PSStarr log initialized: $($now.ToString('yyyy-MM-dd HH:mm:ss.fff'))")
            $allLines.Add("Hostname: $([Environment]::MachineName)")
            $allLines.Add("PowerShell: $($PSVersionTable.PSVersion)")
            $allLines.Add($divider)
        }

        $timestamp = $now.ToString('yyyy-MM-dd HH:mm:ss.fff')
        $severityLabel = $Severity.ToUpperInvariant().PadRight(7)

        foreach ($messageToProcess in $collectedMessages) {
            $messageLines = @($messageToProcess -split "`r?`n")
            $allLines.Add("[$timestamp] [$severityLabel] $($messageLines[0])")

            foreach ($continuationLine in @($messageLines | Select-Object -Skip 1)) {
                $allLines.Add("    $continuationLine")
            }
        }

        $encoding = [Text.UTF8Encoding]::new($false)
        $maxAttempts = $RetryCount + 1

        for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
            $fileStream = $null
            $streamWriter = $null

            try {
                $fileStream = [IO.File]::Open($logFullPath, [IO.FileMode]::Append, [IO.FileAccess]::Write, [IO.FileShare]::Read)
                $streamWriter = [IO.StreamWriter]::new($fileStream, $encoding)

                foreach ($line in $allLines) {
                    $streamWriter.WriteLine($line)
                }

                $streamWriter.Flush()
                break
            }
            catch [IO.IOException] {
                if ($attempt -lt $maxAttempts) {
                    Start-Sleep -Milliseconds $RetryDelayMs
                }
                else {
                    Write-Error "Failed to write '$logFullPath' after $maxAttempts attempts." -ErrorAction Continue
                }
            }
            catch {
                Write-Error "Cannot write '$logFullPath': $($_.Exception.Message)" -ErrorAction Continue
                break
            }
            finally {
                if ($null -ne $streamWriter) {
                    $streamWriter.Dispose()
                }
                elseif ($null -ne $fileStream) {
                    $fileStream.Dispose()
                }
            }
        }

        if (-not $NoConsoleOutput) {
            foreach ($messageToOutput in $collectedMessages) {
                switch ($Severity) {
                    'Success' {
                        Write-Host $messageToOutput -ForegroundColor Green
                    }
                    'Warning' {
                        Write-Warning $messageToOutput
                    }
                    'Error' {
                        Write-Error $messageToOutput -ErrorAction Continue
                    }
                    default {
                        Write-Host $messageToOutput
                    }
                }
            }
        }
    }
}




