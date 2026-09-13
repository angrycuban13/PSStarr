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
