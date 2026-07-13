#Region 'PREFIX' -1

Set-StrictMode -Version 3.0
#EndRegion 'PREFIX'
#Region '.\Private\Get-StarrConfiguration.ps1' -1

function Get-StarrConfiguration {
    <#
    .SYNOPSIS
        Retrieves the persisted PSStarr configuration.

    .DESCRIPTION
        This function retrieves the persisted PSStarr configuration and ensures its instance collection is usable.

    .EXAMPLE
        Get-StarrConfiguration

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Collections.Hashtable]

        This function returns the PSStarr configuration as a hashtable.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()

    $configuration = Import-Configuration -CompanyName 'AngryCuban13' -Name 'PSStarr'

    if ($null -eq $configuration) { return @{Instances = @{} } }

    if (-not $configuration.ContainsKey('Instances') -or $null -eq $configuration.Instances) {
        $configuration.Instances = @{}
    }

    if ($configuration.Instances -isnot [System.Collections.IDictionary]) {
        throw 'The saved Starr instance configuration is invalid. Remove it and create the instances again.'
    }

    $configuration
}







#EndRegion '.\Private\Get-StarrConfiguration.ps1' 47
#Region '.\Private\Invoke-StarrFunctionErrorHandler.ps1' -1

function Invoke-StarrFunctionErrorHandler {
    <#
    .SYNOPSIS
        Emits a sanitized error according to the caller's effective error action.

    .DESCRIPTION
        This function optionally logs a sanitized error and emits it according to the caller's effective error action.

    .PARAMETER Cmdlet
        The calling function's PSCmdlet object.

    .PARAMETER ErrorRecord
        The PowerShell error record to format or emit.

    .PARAMETER OriginalErrorAction
        The caller's effective error action before internal normalization.

    .PARAMETER LogMessage
        A human-readable summary written before detailed error information.

    .PARAMETER LogEntryParameters
        Additional safe parameters supplied to the logging function.

    .PARAMETER SensitiveValue
        Values replaced with the redaction marker.

    .PARAMETER NoLog
        Prevents expected errors from being written to the log.

    .EXAMPLE
        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $_ -OriginalErrorAction $originalErrorAction

    .EXAMPLE
        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -NoLog

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        None.

        This function does not return objects to the pipeline.
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ActionPreference]
        $OriginalErrorAction,

        [Parameter(Mandatory = $false)]
        [System.String]
        $LogMessage,

        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]
        $LogEntryParameters = @{},

        [Parameter(Mandatory = $false)]
        [System.String[]]
        $SensitiveValue,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]
        $NoLog
    )

    if (-not $NoLog) {
        $summary = if ([System.String]::IsNullOrWhiteSpace($LogMessage)) {
            $ErrorRecord.Exception.Message
        }
        else {
            $LogMessage
        }

        $errorDetails = Resolve-StarrErrorRecord -ErrorRecord $ErrorRecord

        $logText = if ($summary -eq $ErrorRecord.Exception.Message) {
            $errorDetails
        }
        else {
            "$summary`n$errorDetails"
        }

        $logText = Protect-StarrSensitiveText -Text $logText -SensitiveValue $SensitiveValue

        $writeLogParameters = @{
            Message         = $logText
            Severity        = 'Error'
            NoConsoleOutput = $true
        }

        foreach ($key in $LogEntryParameters.Keys) {
            if ($key -notin @('Message', 'Severity', 'NoConsoleOutput')) {
                $writeLogParameters[$key] = $LogEntryParameters[$key]
            }
        }

        Write-StarrLogEntry @writeLogParameters
    }

    $ErrorActionPreference = $OriginalErrorAction

    switch ($OriginalErrorAction) {
        'Stop' {
            $Cmdlet.ThrowTerminatingError($ErrorRecord)
        }
        { $_ -in 'SilentlyContinue', 'Ignore' } {
            return
        }
        default {
            $Cmdlet.WriteError($ErrorRecord)
        }
    }
}
#EndRegion '.\Private\Invoke-StarrFunctionErrorHandler.ps1' 126
#Region '.\Private\New-StarrErrorRecord.ps1' -1

function New-StarrErrorRecord {
    <#
    .SYNOPSIS
        Creates a new ErrorRecord object.

    .DESCRIPTION
        This function creates a structured PowerShell error record.

    .PARAMETER Exception
        The exception represented by the new error record.

    .PARAMETER Category
        The PowerShell error category.

    .PARAMETER ErrorId
        The identifier used in the error record.

    .PARAMETER TargetObject
        The object associated with the failure.

    .PARAMETER TargetName
        The name of the failed target.

    .PARAMETER TargetType
        The type of the failed target.

    .PARAMETER Activity
        The operation that failed.

    .PARAMETER Reason
        The reason reported for the failure.

    .PARAMETER RecommendedAction
        Suggested corrective action for the caller.

    .EXAMPLE
        New-StarrErrorRecord -Exception ([System.Exception]::new('Failure')) -Category InvalidOperation

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Management.Automation.ErrorRecord]

        This function returns the constructed PowerShell error record.
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'This function does not change system state.')]
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Exception]
        $Exception,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorCategory]
        $Category,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ErrorId = 'NotSpecified',

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.Object]
        $TargetObject,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TargetName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TargetType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Activity,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Reason,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $RecommendedAction
    )

    process {
        $errRecord = [System.Management.Automation.ErrorRecord]::new($Exception, $ErrorId, $Category, $TargetObject)

        if ($PSBoundParameters.ContainsKey('Activity')) {
            $errRecord.CategoryInfo.Activity = $Activity
        }
        if ($PSBoundParameters.ContainsKey('TargetName')) {
            $errRecord.CategoryInfo.TargetName = $TargetName
        }
        if ($PSBoundParameters.ContainsKey('TargetType')) {
            $errRecord.CategoryInfo.TargetType = $TargetType
        }
        if ($PSBoundParameters.ContainsKey('Reason')) {
            $errRecord.CategoryInfo.Reason = $Reason
        }
        if ($PSBoundParameters.ContainsKey('RecommendedAction')) {
            $errRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($errRecord.Exception.Message)
            $errRecord.ErrorDetails.RecommendedAction = $RecommendedAction
        }

        return $errRecord
    }
}




#EndRegion '.\Private\New-StarrErrorRecord.ps1' 125
#Region '.\Private\Protect-StarrSensitiveText.ps1' -1

function Protect-StarrSensitiveText {
    <#
    .SYNOPSIS
        Redacts sensitive values from text.

    .DESCRIPTION
        This function replaces each supplied sensitive value in text with a redaction marker.

    .PARAMETER Text
        The text to sanitize.

    .PARAMETER SensitiveValue
        The sensitive values to redact.

    .EXAMPLE
        Protect-StarrSensitiveText -Text 'Key=secret' -SensitiveValue 'secret'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.String]

        This function returns the resulting text.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [AllowNull()]
        [System.String]
        $Text,

        [AllowNull()]
        [System.String[]]
        $SensitiveValue
    )

    if ($null -eq $Text) { return $null }

    $sanitized = $Text

    foreach ($value in @($SensitiveValue)) {
        if (-not [System.String]::IsNullOrEmpty($value)) {
            $sanitized = $sanitized.Replace($value, '[REDACTED]')
        }
    }

    $sanitized
}




#EndRegion '.\Private\Protect-StarrSensitiveText.ps1' 56
#Region '.\Private\Resolve-StarrErrorRecord.ps1' -1

function Resolve-StarrErrorRecord {
    <#
    .SYNOPSIS
        Formats an error record as readable diagnostic text.

    .DESCRIPTION
        This function formats a PowerShell error record as readable diagnostic text for logging.

    .PARAMETER ErrorRecord
        The PowerShell error record to format.

    .EXAMPLE
        Resolve-StarrErrorRecord -ErrorRecord $_

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.String]

        This function returns the resulting text.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    process {
        $lines = [System.Collections.Generic.List[System.String]]::new()

        $lines.Add("Exception    : [$($ErrorRecord.Exception.GetType().FullName)] $($ErrorRecord.Exception.Message)")

        $innerException = $ErrorRecord.Exception.InnerException
        $depth = 0

        while ($null -ne $innerException -and $depth -lt 5) {
            $lines.Add("  Inner[$depth]  : [$($innerException.GetType().FullName)] $($innerException.Message)")
            $innerException = $innerException.InnerException
            $depth++
        }

        $lines.Add("Category     : $($ErrorRecord.CategoryInfo.ToString())")
        $lines.Add("ErrorId      : $($ErrorRecord.FullyQualifiedErrorId)")

        if (-not [System.String]::IsNullOrWhiteSpace($ErrorRecord.ScriptStackTrace)) {
            $lines.Add("Stack Trace  :`n$($ErrorRecord.ScriptStackTrace)")
        }

        return $lines -join "`n"
    }
}
#EndRegion '.\Private\Resolve-StarrErrorRecord.ps1' 58
#Region '.\Private\Test-StarrUrl.ps1' -1

function Test-StarrUrl {
    <#
    .SYNOPSIS
        Validates a Starr instance URL.

    .DESCRIPTION
        This function verifies that a value is an absolute HTTP or HTTPS URL with a host.

    .PARAMETER Url
        The absolute URL to validate.

    .EXAMPLE
        Test-StarrUrl -Url 'http://localhost:7878'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Boolean]

        This function returns a Boolean indicating whether the value is valid.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Url
    )

    $uri = $null

    if (-not [uri]::TryCreate($Url, [UriKind]::Absolute, [ref] $uri)) {
        throw 'Url must be an absolute URL.'
    }

    if ($uri.Scheme -notin 'http', 'https') {
        throw 'Url must use HTTP or HTTPS.'
    }

    if ([string]::IsNullOrWhiteSpace($uri.Host)) {
        throw 'Url must include a host.'
    }

    $true
}






#EndRegion '.\Private\Test-StarrUrl.ps1' 55
#Region '.\Private\Write-StarrLogEntry.ps1' -1

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




#EndRegion '.\Private\Write-StarrLogEntry.ps1' 268
#Region '.\Public\Get-StarrApiInfo.ps1' -1

function Get-StarrApiInfo {
    <#
    .SYNOPSIS
        Get-Starr Api Info.

    .DESCRIPTION
        This function retrieves Api Info data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .EXAMPLE
        Get-StarrApiInfo -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrApiInfo -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey
    )

    $request = @{
        Endpoint    = 'api'
        Unversioned = $true
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}



#EndRegion '.\Public\Get-StarrApiInfo.ps1' 71
#Region '.\Public\Get-StarrAutoTagging.ps1' -1

function Get-StarrAutoTagging {
    <#
    .SYNOPSIS
        Get-Starr Auto Tagging.

    .DESCRIPTION
        This function retrieves Auto Tagging data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrAutoTagging -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrAutoTagging -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'autotagging'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrAutoTagging.ps1' 97
#Region '.\Public\Get-StarrAutoTaggingSchema.ps1' -1

function Get-StarrAutoTaggingSchema {
    <#
    .SYNOPSIS
        Get-Starr Auto Tagging Schema.

    .DESCRIPTION
        This function retrieves Auto Tagging Schema data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrAutoTaggingSchema -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrAutoTaggingSchema -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'autotagging/schema'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrAutoTaggingSchema.ps1' 85
#Region '.\Public\Get-StarrBackup.ps1' -1

function Get-StarrBackup {
    <#
    .SYNOPSIS
        Get-Starr Backup.

    .DESCRIPTION
        This function retrieves Backup data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrBackup -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrBackup -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'system/backup'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrBackup.ps1' 85
#Region '.\Public\Get-StarrBlocklist.ps1' -1

function Get-StarrBlocklist {
    <#
    .SYNOPSIS
        Get-Starr Blocklist.

    .DESCRIPTION
        This function retrieves Blocklist data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER MovieId
        The numeric Radarr movie identifier.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrBlocklist -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrBlocklist -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $MovieId,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'blocklist'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSBoundParameters.ContainsKey('MovieId')) {
        $request.Endpoint = "$endpoint/movie"
        $request.ExpectedApplication = 'Radarr'
        $request.Query = @{}

        if ($null -ne $Query) {
            $request.Query = $Query.Clone()
        }

        $request.Query.MovieId = $MovieId
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrBlocklist.ps1' 105
#Region '.\Public\Get-StarrCalendar.ps1' -1

function Get-StarrCalendar {
    <#
    .SYNOPSIS
        Get-Starr Calendar.

    .DESCRIPTION
        This function retrieves Calendar data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrCalendar -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrCalendar -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'calendar'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrCalendar.ps1' 85
#Region '.\Public\Get-StarrCommand.ps1' -1

function Get-StarrCommand {
    <#
    .SYNOPSIS
        Get-Starr Command.

    .DESCRIPTION
        This function retrieves Command data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrCommand -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrCommand -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'command'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrCommand.ps1' 97
#Region '.\Public\Get-StarrCustomFormat.ps1' -1

function Get-StarrCustomFormat {
    <#
    .SYNOPSIS
        Get-Starr Custom Format.

    .DESCRIPTION
        This function retrieves Custom Format data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrCustomFormat -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrCustomFormat -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'customformat'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrCustomFormat.ps1' 97
#Region '.\Public\Get-StarrCustomFormatSchema.ps1' -1

function Get-StarrCustomFormatSchema {
    <#
    .SYNOPSIS
        Get-Starr Custom Format Schema.

    .DESCRIPTION
        This function retrieves Custom Format Schema data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrCustomFormatSchema -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrCustomFormatSchema -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'customformat/schema'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrCustomFormatSchema.ps1' 85
#Region '.\Public\Get-StarrDiskSpace.ps1' -1

function Get-StarrDiskSpace {
    <#
    .SYNOPSIS
        Get-Starr Disk Space.

    .DESCRIPTION
        This function retrieves Disk Space data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrDiskSpace -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrDiskSpace -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'diskspace'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrDiskSpace.ps1' 85
#Region '.\Public\Get-StarrDownloadClient.ps1' -1

function Get-StarrDownloadClient {
    <#
    .SYNOPSIS
        Get-Starr Download Client.

    .DESCRIPTION
        This function retrieves Download Client data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrDownloadClient -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrDownloadClient -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'downloadclient'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrDownloadClient.ps1' 97
#Region '.\Public\Get-StarrDownloadClientSchema.ps1' -1

function Get-StarrDownloadClientSchema {
    <#
    .SYNOPSIS
        Get-Starr Download Client Schema.

    .DESCRIPTION
        This function retrieves Download Client Schema data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrDownloadClientSchema -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrDownloadClientSchema -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'downloadclient/schema'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrDownloadClientSchema.ps1' 85
#Region '.\Public\Get-StarrHealth.ps1' -1

function Get-StarrHealth {
    <#
    .SYNOPSIS
        Get-Starr Health.

    .DESCRIPTION
        This function retrieves Health data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrHealth -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrHealth -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'health'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrHealth.ps1' 85
#Region '.\Public\Get-StarrHistory.ps1' -1

function Get-StarrHistory {
    <#
    .SYNOPSIS
        Retrieves history from a Starr instance.

    .DESCRIPTION
        This function retrieves history from a named Starr instance or an explicit URL and API key, optionally scoped by date or application resource.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Since
        The earliest history timestamp to retrieve.

    .PARAMETER MovieId
        The numeric Radarr movie identifier.

    .PARAMETER SeriesId
        The numeric Sonarr series identifier.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrHistory -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrHistory -Name 'RadarrMain' -MovieId 42

    .EXAMPLE
        Get-StarrHistory -Url 'http://localhost:8989' -ApiKey '<api-key>' -SeriesId 7

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns history response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedMovie')]
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSeries')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitMovie')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeries')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitMovie')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeries')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSince')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSince')]
        [System.DateTime]
        $Since,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedMovie')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitMovie')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $MovieId,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedSeries')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSeries')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $SeriesId,

        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]
        $Query
    )

    $endpoint = 'history'

    $request = @{
        Endpoint = $endpoint
        Query    = @{}
    }

    if ($null -ne $Query) {
        $request.Query = $Query.Clone()
    }

    if ($PSBoundParameters.ContainsKey('Since')) {
        $request.Endpoint = "$endpoint/since"
        $request.Query.Date = $Since.ToString('o')
    }

    if ($PSBoundParameters.ContainsKey('MovieId')) {
        $request.Endpoint = "$endpoint/movie"
        $request.Query.MovieId = $MovieId
        $request.ExpectedApplication = 'Radarr'
    }

    if ($PSBoundParameters.ContainsKey('SeriesId')) {
        $request.Endpoint = "$endpoint/series"
        $request.Query.SeriesId = $SeriesId
        $request.ExpectedApplication = 'Sonarr'
    }

    if ($PSCmdlet.ParameterSetName -like 'Named*') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}
#EndRegion '.\Public\Get-StarrHistory.ps1' 136
#Region '.\Public\Get-StarrIndexer.ps1' -1

function Get-StarrIndexer {
    <#
    .SYNOPSIS
        Get-Starr Indexer.

    .DESCRIPTION
        This function retrieves Indexer data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrIndexer -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrIndexer -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'indexer'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrIndexer.ps1' 97
#Region '.\Public\Get-StarrIndexerSchema.ps1' -1

function Get-StarrIndexerSchema {
    <#
    .SYNOPSIS
        Get-Starr Indexer Schema.

    .DESCRIPTION
        This function retrieves Indexer Schema data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrIndexerSchema -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrIndexerSchema -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'indexer/schema'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrIndexerSchema.ps1' 85
#Region '.\Public\Get-StarrInstance.ps1' -1

function Get-StarrInstance {
    <#
    .SYNOPSIS
        Get-Starr Instance.

    .DESCRIPTION
        This function retrieves saved Starr instances without exposing API keys.

    .PARAMETER Name
        The name of the saved Starr instance.

    .EXAMPLE
        Get-StarrInstance

    .EXAMPLE
        Get-StarrInstance -Name 'RadarrMain'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Management.Automation.PSCustomObject]

        This function returns Starr instance configuration objects.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name
    )

    if ($PSBoundParameters.ContainsKey('ErrorAction')) {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $PSBoundParameters.ErrorAction
    }
    else {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $ErrorActionPreference
    }

    $ErrorActionPreference = 'Stop'

    try {
        $configuration = Get-StarrConfiguration
    }
    catch {
        $message = "Unable to load the saved Starr instance configuration. $($_.Exception.Message)"
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ReadError -ErrorId 'StarrConfigurationReadFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        return
    }

    $instanceNames = @($configuration.Instances.Keys | Sort-Object)

    if ($PSBoundParameters.ContainsKey('Name')) {
        if (-not $configuration.Instances.Contains($Name)) {
            Write-Warning "Starr instance `"$Name`" was not found."
            return
        }

        $instanceNames = @($Name)
    }

    if ($instanceNames.Count -eq 0) {
        Write-Warning 'No Starr instances were found. Run "Set-StarrInstance" to create a new instance.'
        return
    }

    foreach ($instanceName in $instanceNames) {
        $instance = $configuration.Instances[$instanceName]

        [PSCustomObject]@{
            Name        = $instanceName
            Application = $instance.Application
            Url         = $instance.Url
            ApiKey      = '********'
        }
    }
}








#EndRegion '.\Public\Get-StarrInstance.ps1' 93
#Region '.\Public\Get-StarrNotification.ps1' -1

function Get-StarrNotification {
    <#
    .SYNOPSIS
        Get-Starr Notification.

    .DESCRIPTION
        This function retrieves Notification data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrNotification -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrNotification -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'notification'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrNotification.ps1' 97
#Region '.\Public\Get-StarrNotificationSchema.ps1' -1

function Get-StarrNotificationSchema {
    <#
    .SYNOPSIS
        Get-Starr Notification Schema.

    .DESCRIPTION
        This function retrieves Notification Schema data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrNotificationSchema -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrNotificationSchema -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'notification/schema'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrNotificationSchema.ps1' 85
#Region '.\Public\Get-StarrQualityProfile.ps1' -1

function Get-StarrQualityProfile {
    <#
    .SYNOPSIS
        Get-Starr Quality Profile.

    .DESCRIPTION
        This function retrieves Quality Profile data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrQualityProfile -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrQualityProfile -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'qualityprofile'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrQualityProfile.ps1' 97
#Region '.\Public\Get-StarrQualityProfileSchema.ps1' -1

function Get-StarrQualityProfileSchema {
    <#
    .SYNOPSIS
        Get-Starr Quality Profile Schema.

    .DESCRIPTION
        This function retrieves Quality Profile Schema data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrQualityProfileSchema -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrQualityProfileSchema -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'qualityprofile/schema'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrQualityProfileSchema.ps1' 85
#Region '.\Public\Get-StarrQueue.ps1' -1

function Get-StarrQueue {
    <#
    .SYNOPSIS
        Get-Starr Queue.

    .DESCRIPTION
        This function retrieves Queue data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrQueue -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrQueue -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'queue'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrQueue.ps1' 85
#Region '.\Public\Get-StarrQueueDetail.ps1' -1

function Get-StarrQueueDetail {
    <#
    .SYNOPSIS
        Get-Starr Queue Detail.

    .DESCRIPTION
        This function retrieves Queue Detail data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrQueueDetail -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrQueueDetail -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'queue/details'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrQueueDetail.ps1' 85
#Region '.\Public\Get-StarrQueueStatus.ps1' -1

function Get-StarrQueueStatus {
    <#
    .SYNOPSIS
        Get-Starr Queue Status.

    .DESCRIPTION
        This function retrieves Queue Status data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrQueueStatus -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrQueueStatus -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'queue/status'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrQueueStatus.ps1' 85
#Region '.\Public\Get-StarrRadarrCollection.ps1' -1

function Get-StarrRadarrCollection {
    <#
    .SYNOPSIS
        Get-Starr Radarr Collection.

    .DESCRIPTION
        This function retrieves Radarr Collection data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrRadarrCollection -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrRadarrCollection -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'collection'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Radarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrRadarrCollection.ps1' 99
#Region '.\Public\Get-StarrRadarrCredit.ps1' -1

function Get-StarrRadarrCredit {
    <#
    .SYNOPSIS
        Get-Starr Radarr Credit.

    .DESCRIPTION
        This function retrieves Radarr Credit data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrRadarrCredit -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrRadarrCredit -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'credit'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Radarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrRadarrCredit.ps1' 99
#Region '.\Public\Get-StarrRadarrCutoff.ps1' -1

function Get-StarrRadarrCutoff {
    <#
    .SYNOPSIS
        Get-Starr Radarr Cutoff.

    .DESCRIPTION
        This function retrieves Radarr Cutoff data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrRadarrCutoff -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrRadarrCutoff -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'wanted/cutoff'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Radarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrRadarrCutoff.ps1' 87
#Region '.\Public\Get-StarrRadarrMissing.ps1' -1

function Get-StarrRadarrMissing {
    <#
    .SYNOPSIS
        Get-Starr Radarr Missing.

    .DESCRIPTION
        This function retrieves Radarr Missing data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrRadarrMissing -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrRadarrMissing -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'wanted/missing'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Radarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrRadarrMissing.ps1' 87
#Region '.\Public\Get-StarrRadarrMovie.ps1' -1

function Get-StarrRadarrMovie {
    <#
    .SYNOPSIS
        Get-Starr Radarr Movie.

    .DESCRIPTION
        This function retrieves Radarr Movie data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrRadarrMovie -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrRadarrMovie -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'movie'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Radarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrRadarrMovie.ps1' 99
#Region '.\Public\Get-StarrRadarrMovieFile.ps1' -1

function Get-StarrRadarrMovieFile {
    <#
    .SYNOPSIS
        Get-Starr Radarr Movie File.

    .DESCRIPTION
        This function retrieves Radarr Movie File data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrRadarrMovieFile -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrRadarrMovieFile -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'moviefile'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Radarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrRadarrMovieFile.ps1' 99
#Region '.\Public\Get-StarrRadarrMovieLookup.ps1' -1

function Get-StarrRadarrMovieLookup {
    <#
    .SYNOPSIS
        Get-Starr Radarr Movie Lookup.

    .DESCRIPTION
        This function retrieves Radarr Movie Lookup data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Term
        The lookup search term.

    .PARAMETER ImdbId
        The IMDb title identifier.

    .PARAMETER TmdbId
        The TMDB movie identifier.

    .EXAMPLE
        Get-StarrRadarrMovieLookup -Name 'RadarrMain' -Term 'example'

    .EXAMPLE
        Get-StarrRadarrMovieLookup -Url 'http://localhost:7878' -ApiKey '<api-key>' -Term 'example'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NamedTerm')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedTerm')]
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedImdb')]
        [Parameter(Mandatory = $true, ParameterSetName = 'NamedTmdb')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTerm')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitImdb')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTmdb')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTerm')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitImdb')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTmdb')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedTerm')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTerm')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Term,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedImdb')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitImdb')]
        [ValidatePattern('^tt\d+$')]
        [string]
        $ImdbId,

        [Parameter(Mandatory = $true, ParameterSetName = 'NamedTmdb')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitTmdb')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $TmdbId
    )

    $request = @{ExpectedApplication = 'Radarr' }
    $endpoint = 'movie/lookup'

    if ($PSCmdlet.ParameterSetName -like '*Imdb') {
        $request.Endpoint = "$endpoint/imdb"
        $request.Query = @{
            ImdbId = $ImdbId
        }
    }
    elseif ($PSCmdlet.ParameterSetName -like '*Tmdb') {
        $request.Endpoint = "$endpoint/tmdb"
        $request.Query = @{
            TmdbId = $TmdbId
        }
    }
    else {
        $request.Endpoint = $endpoint
        $request.Query = @{
            Term = $Term
        }
    }

    if ($PSCmdlet.ParameterSetName -like 'Named*') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrRadarrMovieLookup.ps1' 123
#Region '.\Public\Get-StarrRemotePathMapping.ps1' -1

function Get-StarrRemotePathMapping {
    <#
    .SYNOPSIS
        Get-Starr Remote Path Mapping.

    .DESCRIPTION
        This function retrieves Remote Path Mapping data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrRemotePathMapping -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrRemotePathMapping -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'remotepathmapping'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrRemotePathMapping.ps1' 97
#Region '.\Public\Get-StarrRootFolder.ps1' -1

function Get-StarrRootFolder {
    <#
    .SYNOPSIS
        Get-Starr Root Folder.

    .DESCRIPTION
        This function retrieves Root Folder data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrRootFolder -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrRootFolder -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'rootfolder'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrRootFolder.ps1' 97
#Region '.\Public\Get-StarrSonarrCutoff.ps1' -1

function Get-StarrSonarrCutoff {
    <#
    .SYNOPSIS
        Get-Starr Sonarr Cutoff.

    .DESCRIPTION
        This function retrieves Sonarr Cutoff data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrSonarrCutoff -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrSonarrCutoff -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'wanted/cutoff'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }
    $request.ExpectedApplication = 'Sonarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrSonarrCutoff.ps1' 98
#Region '.\Public\Get-StarrSonarrEpisode.ps1' -1

function Get-StarrSonarrEpisode {
    <#
    .SYNOPSIS
        Get-Starr Sonarr Episode.

    .DESCRIPTION
        This function retrieves Sonarr Episode data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrSonarrEpisode -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrSonarrEpisode -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'episode'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Sonarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrSonarrEpisode.ps1' 99
#Region '.\Public\Get-StarrSonarrEpisodeFile.ps1' -1

function Get-StarrSonarrEpisodeFile {
    <#
    .SYNOPSIS
        Get-Starr Sonarr Episode File.

    .DESCRIPTION
        This function retrieves Sonarr Episode File data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrSonarrEpisodeFile -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrSonarrEpisodeFile -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'episodefile'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Sonarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrSonarrEpisodeFile.ps1' 99
#Region '.\Public\Get-StarrSonarrMissing.ps1' -1

function Get-StarrSonarrMissing {
    <#
    .SYNOPSIS
        Get-Starr Sonarr Missing.

    .DESCRIPTION
        This function retrieves Sonarr Missing data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrSonarrMissing -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrSonarrMissing -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'wanted/missing'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Sonarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrSonarrMissing.ps1' 99
#Region '.\Public\Get-StarrSonarrSeries.ps1' -1

function Get-StarrSonarrSeries {
    <#
    .SYNOPSIS
        Get-Starr Sonarr Series.

    .DESCRIPTION
        This function retrieves Sonarr Series data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrSonarrSeries -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrSonarrSeries -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'series'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    $request.ExpectedApplication = 'Sonarr'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrSonarrSeries.ps1' 99
#Region '.\Public\Get-StarrSonarrSeriesLookup.ps1' -1

function Get-StarrSonarrSeriesLookup {
    <#
    .SYNOPSIS
        Get-Starr Sonarr Series Lookup.

    .DESCRIPTION
        This function retrieves Sonarr Series Lookup data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Term
        The lookup search term.

    .EXAMPLE
        Get-StarrSonarrSeriesLookup -Name 'RadarrMain' -Term 'example'

    .EXAMPLE
        Get-StarrSonarrSeriesLookup -Url 'http://localhost:7878' -ApiKey '<api-key>' -Term 'example'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Term
    )

    $request = @{
        Endpoint            = 'series/lookup'
        ExpectedApplication = 'Sonarr'
        Query               = @{
            Term = $Term
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrSonarrSeriesLookup.ps1' 84
#Region '.\Public\Get-StarrSystemStatus.ps1' -1

function Get-StarrSystemStatus {
    <#
    .SYNOPSIS
        Retrieves system status information from a Starr instance.

    .DESCRIPTION
        This function retrieves system status information from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrSystemStatus -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrSystemStatus -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns system status response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'system/status'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}
#EndRegion '.\Public\Get-StarrSystemStatus.ps1' 80
#Region '.\Public\Get-StarrTag.ps1' -1

function Get-StarrTag {
    <#
    .SYNOPSIS
        Get-Starr Tag.

    .DESCRIPTION
        This function retrieves Tag data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrTag -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrTag -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'tag'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrTag.ps1' 97
#Region '.\Public\Get-StarrTagDetail.ps1' -1

function Get-StarrTagDetail {
    <#
    .SYNOPSIS
        Get-Starr Tag Detail.

    .DESCRIPTION
        This function retrieves Tag Detail data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrTagDetail -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrTagDetail -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'tag/detail'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrTagDetail.ps1' 97
#Region '.\Public\Get-StarrTask.ps1' -1

function Get-StarrTask {
    <#
    .SYNOPSIS
        Get-Starr Task.

    .DESCRIPTION
        This function retrieves Task data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Id
        The numeric identifier of a single API resource.

    .EXAMPLE
        Get-StarrTask -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrTask -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id
    )

    $endpoint = 'system/task'

    if ($PSBoundParameters.ContainsKey('Id')) {
        $endpoint += "/$Id"
    }

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrTask.ps1' 97
#Region '.\Public\Get-StarrUpdate.ps1' -1

function Get-StarrUpdate {
    <#
    .SYNOPSIS
        Get-Starr Update.

    .DESCRIPTION
        This function retrieves Update data from a named Starr instance or an explicit URL and API key.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .EXAMPLE
        Get-StarrUpdate -Name 'RadarrMain'

    .EXAMPLE
        Get-StarrUpdate -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Query
    )

    $endpoint = 'update'

    $request = @{
        Endpoint = $endpoint
    }

    if ($null -ne $Query) {
        $request.Query = $Query
    }

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $request.Name = $Name
    }
    else {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }

    Invoke-StarrApiRequest @request
}





#EndRegion '.\Public\Get-StarrUpdate.ps1' 85
#Region '.\Public\Invoke-StarrApiRequest.ps1' -1

function Invoke-StarrApiRequest {
    <#
    .SYNOPSIS
        Invoke-Starr Api Request.

    .DESCRIPTION
        This function resolves a Starr instance, constructs an authenticated API request, invokes it, and returns the deserialized response.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .PARAMETER Endpoint
        The relative API endpoint path.

    .PARAMETER ApiVersion
        The version segment used in versioned API URLs.

    .PARAMETER Method
        The HTTP method used for the request.

    .PARAMETER Query
        Query-string keys and values appended to the request URL.

    .PARAMETER Body
        The request body. Non-string values are serialized as JSON.

    .PARAMETER ContentType
        The request body content type.

    .PARAMETER ExpectedApplication
        The application type required by an application-specific wrapper.

    .PARAMETER Unversioned
        Builds the request without an API version segment.

    .EXAMPLE
        Invoke-StarrApiRequest -Name 'RadarrMain' -Endpoint 'health'

    .EXAMPLE
        Invoke-StarrApiRequest -Url 'http://localhost:7878' -ApiKey '<api-key>' -Endpoint 'health'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]

        This function returns response objects retrieved from the Starr API.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Endpoint,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiVersion = 'v3',

        [Parameter(Mandatory = $false)]
        [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
        [System.String]
        $Method = 'GET',

        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]
        $Query,

        [Parameter(Mandatory = $false)]
        [System.Object]
        $Body,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ContentType = 'application/json',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Radarr', 'Sonarr', 'Lidarr')]
        [System.String]
        $ExpectedApplication,

        [Parameter(Mandatory = $false)]
        [switch]
        $Unversioned
    )

    if ($PSBoundParameters.ContainsKey('ErrorAction')) {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $PSBoundParameters.ErrorAction
    }
    else {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $ErrorActionPreference
    }
    $ErrorActionPreference = 'Stop'

    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        try {
            $configuration = Get-StarrConfiguration
        }
        catch {
            $message = "Unable to load the saved Starr instance configuration. $($_.Exception.Message)"
            $exception = [System.InvalidOperationException]::new($message, $_.Exception)
            $errorRecord = New-StarrErrorRecord -Exception $exception -Category ReadError -ErrorId 'StarrConfigurationReadFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

            Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
            return
        }

        if (-not $configuration.Instances.Contains($Name)) {
            $message = "Starr instance '$Name' was not found."
            $exception = [System.Management.Automation.ItemNotFoundException]::new($message)
            $errorRecord = New-StarrErrorRecord -Exception $exception -Category ObjectNotFound -ErrorId 'StarrInstanceNotFound' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name -RecommendedAction 'Create the instance with Set-StarrInstance or specify an existing instance name.'

            Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -NoLog
            return
        }

        $instance = $configuration.Instances[$Name]

        if ($PSBoundParameters.ContainsKey('ExpectedApplication') -and $instance.Application -ne $ExpectedApplication) {
            $message = "Starr instance '$Name' is '$($instance.Application)', not '$ExpectedApplication'."
            $exception = [System.ArgumentException]::new($message, 'Name')
            $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrApplicationMismatch' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name -RecommendedAction "Specify an instance configured for $ExpectedApplication."

            Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -NoLog
            return
        }

        $Url = $instance.Url
        $ApiKey = $instance.ApiKey
    }

    $baseUrl = $Url.TrimEnd('/')
    $normalizedEndpoint = $Endpoint.Trim('/')

    $requestUri = if ($Unversioned) {
        "$baseUrl/$normalizedEndpoint"
    }
    else {
        $normalizedApiVersion = $ApiVersion.Trim('/')

        "$baseUrl/api/$normalizedApiVersion/$normalizedEndpoint"
    }

    if ($null -ne $Query -and $Query.Count -gt 0) {
        $queryParts = foreach ($key in @($Query.Keys | Sort-Object)) {
            foreach ($value in @($Query[$key])) {
                $escapedKey = [System.Uri]::EscapeDataString([System.String] $key)
                $escapedValue = [System.Uri]::EscapeDataString([System.String] $value)

                "$escapedKey=$escapedValue"
            }
        }

        $requestUri += '?' + ($queryParts -join '&')
    }

    $parameters = @{
        Uri         = $requestUri
        Method      = $Method
        Headers     = @{
            'X-Api-Key' = $ApiKey
        }
        ErrorAction = $ErrorActionPreference
        Verbose     = $VerbosePreference
        Debug       = $DebugPreference
    }

    if ($PSBoundParameters.ContainsKey('Body')) {
        $parameters.ContentType = $ContentType
        $parameters.Body = if ($Body -is [string]) {
            $Body
        }
        else {
            $Body | ConvertTo-Json -Depth 20
        }
    }

    Write-Verbose "Invoking $Method request to `"$requestUri`"."

    try {
        Invoke-RestMethod @parameters
    }
    catch {
        $detailParts = @($_.Exception.Message)

        if ($null -ne $_.ErrorDetails -and -not [string]::IsNullOrWhiteSpace($_.ErrorDetails.Message)) {
            $detailParts += $_.ErrorDetails.Message
        }

        $details = Protect-StarrSensitiveText -Text ($detailParts -join ' ') -SensitiveValue @($ApiKey)
        $message = "Starr API $Method request to '$requestUri' failed. $($details.Trim())"
        $exception = [System.Net.Http.HttpRequestException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ConnectionError -ErrorId 'StarrApiRequestFailed' -TargetObject $requestUri -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message -SensitiveValue @($ApiKey)
        return
    }
}















#EndRegion '.\Public\Invoke-StarrApiRequest.ps1' 241
#Region '.\Public\Remove-StarrInstance.ps1' -1

function Remove-StarrInstance {
    <#
    .SYNOPSIS
        Removes a saved Starr instance.

    .DESCRIPTION
        This function removes a saved Starr instance and cleans up empty configuration directories.

    .PARAMETER Name
        The name of the saved Starr instance.

    .EXAMPLE
        Remove-StarrInstance -Name 'RadarrMain' -Confirm:$false

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        None.

        This function does not return objects to the pipeline.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.Void])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $Name
    )

    if ($PSBoundParameters.ContainsKey('ErrorAction')) {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $PSBoundParameters.ErrorAction
    }
    else {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $ErrorActionPreference
    }

    $ErrorActionPreference = 'Stop'

    try {
        $configuration = Get-StarrConfiguration
    }
    catch {
        $message = "Unable to load the saved Starr instance configuration. $($_.Exception.Message)"
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ReadError -ErrorId 'StarrConfigurationReadFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        return
    }

    if (-not $configuration.Instances.Contains($Name)) {
        Write-Warning "Starr instance '$Name' was not found."
        return
    }

    if (-not $PSCmdlet.ShouldProcess($Name, 'Remove Starr instance')) {
        return
    }

    $configuration.Instances.Remove($Name)

    if ($configuration.Instances.Count -gt 0) {
        try {
            Export-Configuration -InputObject $configuration -CompanyName 'AngryCuban13' -Name 'PSStarr' -Scope User -AsHashtable
        }
        catch {
            $message = "Unable to save the Starr instance configuration after removing '$Name'. $($_.Exception.Message)"
            $exception = [System.InvalidOperationException]::new($message, $_.Exception)
            $errorRecord = New-StarrErrorRecord -Exception $exception -Category WriteError -ErrorId 'StarrConfigurationWriteFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

            Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        }

        return
    }

    $module = Get-Module -Name PSStarr

    if ($null -eq $module) {
        $message = 'Unable to resolve the loaded PSStarr module.'
        $exception = [System.InvalidOperationException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ResourceUnavailable -ErrorId 'StarrModuleNotLoaded' -TargetObject 'PSStarr' -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        return
    }

    try {
        $configurationPath = $module | Get-ConfigurationPath -Scope User -SkipCreatingFolder
        $configurationFile = Join-Path -Path $configurationPath -ChildPath 'Configuration.psd1'
        $authorPath = Split-Path -Path $configurationPath -Parent
    }
    catch {
        $message = "Unable to resolve the PSStarr configuration path. $($_.Exception.Message)"
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ReadError -ErrorId 'StarrConfigurationPathFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        return
    }

    if ((Split-Path -Path $configurationPath -Leaf) -ne $module.Name -or
        (Split-Path -Path $authorPath -Leaf) -ne $module.CompanyName) {
        $message = "Configuration returned an unexpected path: '$configurationPath'."
        $exception = [System.InvalidOperationException]::new($message)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidData -ErrorId 'StarrConfigurationPathInvalid' -TargetObject $configurationPath -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
        return
    }

    try {
        if (Test-Path -LiteralPath $configurationFile -PathType Leaf) {
            Remove-Item -LiteralPath $configurationFile -Force -ErrorAction Stop
        }

        foreach ($directory in @($configurationPath, $authorPath)) {
            if (Test-Path -LiteralPath $directory -PathType Container) {
                $children = @(Get-ChildItem -LiteralPath $directory -Force -ErrorAction Stop)

                if ($children.Count -eq 0) {
                    Remove-Item -LiteralPath $directory -Force -ErrorAction Stop
                }
            }
        }
    }
    catch {
        $message = "Unable to remove the final Starr instance configuration. $($_.Exception.Message)"
        $exception = [System.IO.IOException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category WriteError -ErrorId 'StarrConfigurationRemoveFailed' -TargetObject $configurationPath -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message
    }
}
#EndRegion '.\Public\Remove-StarrInstance.ps1' 139
#Region '.\Public\Set-StarrInstance.ps1' -1

function Set-StarrInstance {
    <#
    .SYNOPSIS
        Set-Starr Instance.

    .DESCRIPTION
        This function creates or replaces a named Starr instance in persistent user configuration.

    .PARAMETER Name
        The name of the saved Starr instance.

    .PARAMETER Application
        The Starr application type. Valid values are Radarr, Sonarr, and Lidarr.

    .PARAMETER Url
        The absolute base URL of the Starr instance.

    .PARAMETER ApiKey
        The API key used to authenticate with the Starr instance.

    .EXAMPLE
        Set-StarrInstance -Name 'RadarrMain' -Application Radarr -Url 'http://localhost:7878' -ApiKey '<api-key>'

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Management.Automation.PSCustomObject]

        This function returns Starr instance configuration objects.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('Radarr', 'Sonarr', 'Lidarr')]
        [string]
        $Application,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [string]
        $Url,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateNotNullOrWhiteSpace()]
        [string]
        $ApiKey
    )

    if ($PSBoundParameters.ContainsKey('ErrorAction')) {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $PSBoundParameters.ErrorAction
    }
    else {
        $originalErrorAction = [System.Management.Automation.ActionPreference] $ErrorActionPreference
    }

    $ErrorActionPreference = 'Stop'

    try {
        $configuration = Get-StarrConfiguration
    }
    catch {
        $message = "Unable to load the saved Starr instance configuration. $($_.Exception.Message)"
        $message = Protect-StarrSensitiveText -Text $message -SensitiveValue @($ApiKey)
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ReadError -ErrorId 'StarrConfigurationReadFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message -SensitiveValue @($ApiKey)
        return
    }

    $configuration.Instances[$Name] = [ordered]@{
        Application = $Application
        Url         = $Url.TrimEnd('/')
        ApiKey      = $ApiKey
    }

    if (-not $PSCmdlet.ShouldProcess($Name, 'Save Starr instance')) {
        return
    }

    try {
        Export-Configuration -InputObject $configuration -CompanyName 'AngryCuban13' -Name 'PSStarr' -Scope User -AsHashtable
    }
    catch {
        $message = "Unable to save Starr instance '$Name'. $($_.Exception.Message)"
        $message = Protect-StarrSensitiveText -Text $message -SensitiveValue @($ApiKey)
        $exception = [System.InvalidOperationException]::new($message, $_.Exception)
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category WriteError -ErrorId 'StarrConfigurationWriteFailed' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name

        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -LogMessage $message -SensitiveValue @($ApiKey)
        return
    }

    [PSCustomObject]@{
        Name        = $Name
        Application = $Application
        Url         = $Url.TrimEnd('/')
        ApiKey      = '********'
    }
}






#EndRegion '.\Public\Set-StarrInstance.ps1' 116
