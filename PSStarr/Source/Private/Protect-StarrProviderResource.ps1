function Protect-StarrProviderResource {
    <#
    .SYNOPSIS
        Copies provider resources with secret values redacted.

    .DESCRIPTION
        This function returns a sanitized copy of a provider resource. It redacts marked private fields, password fields, and known credential properties. It does not detect secrets in arbitrary text.

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

    # Preserve nested collections as single values during recursive copying.
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

    $safeResource = [PSCustomObject]$safe

    # Preserve PSStarr type names on the sanitized copy.
    $typeNames = @($Resource.PSObject.TypeNames | Where-Object { $_ -like 'PSStarr.*' })

    for ($index = $typeNames.Count - 1; $index -ge 0; $index--) {
        $safeResource.PSObject.TypeNames.Insert(0, $typeNames[$index])
    }

    $safeResource
}
