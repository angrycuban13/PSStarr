function Protect-StarrProviderResource {
    <#
    .SYNOPSIS
        Copies provider resources with secret values redacted.

    .DESCRIPTION
        This function recursively copies provider resources, including fields and presets, without modifying the original objects. Fields marked with non-normal privacy, password input types, or credential names are redacted. Known credential properties are also redacted. This is not a general detector for secrets embedded in arbitrary text.

    .PARAMETER Resource
        The deserialized provider resource or nested value to copy safely.

    .EXAMPLE
        Protect-StarrProviderResource -Resource $provider

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Object]
        [System.Object[]]

        This function returns a copy with recognizable provider credential values redacted.
    #>
    [CmdletBinding()]
    [OutputType([System.Object], [System.Object[]])]
    param(
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Resource
    )

    if ($null -eq $Resource) {
        return $null
    }

    if ($Resource -is [System.Collections.IDictionary]) {
        $properties = @{}

        foreach ($key in $Resource.Keys) {
            $properties[[System.String]$key] = $Resource[$key]
        }
    }
    elseif ($Resource -is [System.Collections.IEnumerable] -and $Resource -isnot [System.String]) {
        $items = @(
            foreach ($item in $Resource) {
                Protect-StarrProviderResource -Resource $item
            }
        )

        Write-Output $items -NoEnumerate

        return
    }
    elseif ($Resource -is [System.Management.Automation.PSCustomObject]) {
        $properties = @{}

        foreach ($property in $Resource.PSObject.Properties) {
            $properties[$property.Name] = $property.Value
        }
    }
    else {
        return $Resource
    }

    $credentialName = '^(api[-_]?key|password|passwordConfirmation|sslCertPassword|proxyPassword|accessToken|refreshToken|token|secret|clientSecret)$'
    $sensitiveField = ($properties.ContainsKey('privacy') -and
        -not [System.String]::IsNullOrWhiteSpace([System.String]$properties.privacy) -and
        [System.String]$properties.privacy -ne 'normal') -or
    ($properties.ContainsKey('type') -and $properties.type -eq 'password') -or
    ($properties.ContainsKey('name') -and $properties.name -match $credentialName)

    $safe = [ordered]@{}

    foreach ($key in $properties.Keys) {
        if ($key -match $credentialName -or ($key -eq 'value' -and $sensitiveField)) {
            $safe[$key] = '[REDACTED]'
        }
        elseif ($properties[$key] -is [System.Collections.IEnumerable] -and
            $properties[$key] -isnot [System.String] -and
            @($properties[$key]).Count -eq 0) {
            $safe[$key] = [System.Object[]]@()
        }
        else {
            $safe[$key] = Protect-StarrProviderResource -Resource $properties[$key]
        }
    }

    [pscustomobject]$safe
}
