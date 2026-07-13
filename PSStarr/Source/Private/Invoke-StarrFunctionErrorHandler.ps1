function Invoke-StarrFunctionErrorHandler {
    <#
    .SYNOPSIS
        Logs and emits a sanitized error according to the caller's effective error action.

    .DESCRIPTION
        This function logs a sanitized error and emits it according to the caller's effective error action.

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

    .EXAMPLE
        Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $_ -OriginalErrorAction $originalErrorAction

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        None.

        This function does not return objects to the pipeline.
    #>
    [CmdletBinding()]
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
        $SensitiveValue
    )

    $summary = if ([System.String]::IsNullOrWhiteSpace($LogMessage)) {
        $ErrorRecord.Exception.Message
    }
    else {
        $LogMessage
    }

    $logText = "$summary`n$(Resolve-StarrErrorRecord -ErrorRecord $ErrorRecord)"
    $logText = Protect-StarrSensitiveText -Text $logText -SensitiveValue $SensitiveValue

    $writeLogParameters = @{
        Message         = $logText
        Severity        = 'Error'
        NoConsoleOutput = $true
    }

    foreach ($key in $LogEntryParameters.Keys) {
        if ($key -notin @('Message', 'Severity', 'NoConsoleOutput')) {
            $writeLogParameters[$key] = $LogEntryParameters[$key]
            $errorDetails = Resolve-StarrErrorRecord -ErrorRecord $ErrorRecord

            $logText = if ($summary -eq $ErrorRecord.Exception.Message) {
                $errorDetails
            }
            else {
                "$summary`n$errorDetails"
            }

        }

        Write-StarrLogEntry @writeLogParameters

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
