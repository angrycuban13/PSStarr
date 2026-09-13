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
