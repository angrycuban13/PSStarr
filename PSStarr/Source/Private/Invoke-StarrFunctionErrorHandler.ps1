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
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord,

        [Parameter(Mandatory)]
        [System.Management.Automation.ActionPreference]
        $OriginalErrorAction,

        [Parameter()]
        [System.String]
        $LogMessage,

        [Parameter()]
        [System.Collections.Hashtable]
        $LogEntryParameters = @{},

        [Parameter()]
        [System.String[]]
        $SensitiveValue,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $NoLog
    )

    if (-not $NoLog -and $env:PSSTARR_LOG_DISABLED -cne '1') {
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

        if (-not [System.String]::IsNullOrWhiteSpace($env:PSSTARR_LOG_DIRECTORY)) {
            $writeLogParameters.LogFileDirectory = $env:PSSTARR_LOG_DIRECTORY
        }

        foreach ($key in $LogEntryParameters.Keys) {
            if ($key -notin @('Message', 'Severity', 'NoConsoleOutput')) {
                $writeLogParameters[$key] = $LogEntryParameters[$key]
            }
        }

        try {
            Write-PSStarrLogEntry @writeLogParameters -ErrorAction Stop
        }
        catch {
            # A logging failure must never replace the original operation's error.
            Write-Warning 'PSStarr could not write the operational error log.' -WarningAction Continue
        }
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
