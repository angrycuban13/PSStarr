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
        The version segment used in versioned API URLs. When omitted, saved Prowlarr instances and explicit requests with ExpectedApplication Prowlarr use v1; other requests use v3.

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
        [Parameter(Mandatory = $false, ParameterSetName = 'Named')]
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
        [ValidateSet('Radarr', 'Sonarr', 'Prowlarr')]
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

    $resolvedApplication = $ExpectedApplication

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

        if ($PSBoundParameters.ContainsKey('Name')) {
            if (-not $configuration.Instances.Contains($Name)) {
                $message = "Starr instance '$Name' was not found."
                $exception = [System.Management.Automation.ItemNotFoundException]::new($message)
                $errorRecord = New-StarrErrorRecord -Exception $exception -Category ObjectNotFound -ErrorId 'StarrInstanceNotFound' -TargetObject $Name -Activity $MyInvocation.MyCommand.Name -RecommendedAction 'Create the instance with Set-PSStarrInstance or specify an existing instance name.'

                Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -NoLog
                return
            }

            $instanceName = $Name
        }
        else {
            $instanceNames = @($configuration.Instances.Keys | Sort-Object)

            if ($PSBoundParameters.ContainsKey('ExpectedApplication')) {
                $instanceNames = @(
                    $instanceNames | Where-Object {
                        $configuration.Instances[$_].Application -eq $ExpectedApplication
                    }
                )
            }

            if ($instanceNames.Count -eq 0) {
                $targetApplication = if ($PSBoundParameters.ContainsKey('ExpectedApplication')) {
                    " for $ExpectedApplication"
                }
                else {
                    ''
                }

                $message = "No Starr instances$targetApplication were found."
                $exception = [System.Management.Automation.ItemNotFoundException]::new($message)
                $errorRecord = New-StarrErrorRecord -Exception $exception -Category ObjectNotFound -ErrorId 'StarrInstanceNotFound' -TargetObject $ExpectedApplication -Activity $MyInvocation.MyCommand.Name -RecommendedAction 'Create an instance with Set-PSStarrInstance.'

                Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -NoLog
                return
            }

            if ($instanceNames.Count -gt 1) {
                $candidateList = $instanceNames -join ', '
                $message = "Multiple Starr instances match this request: $candidateList. Specify Name."
                $exception = [System.InvalidOperationException]::new($message)
                $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrInstanceAmbiguous' -TargetObject $instanceNames -Activity $MyInvocation.MyCommand.Name -RecommendedAction 'Specify the desired instance with Name.'

                Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -NoLog
                return
            }

            $instanceName = $instanceNames[0]
        }

        $instance = $configuration.Instances[$instanceName]

        $resolvedApplication = $instance.Application

        if ($PSBoundParameters.ContainsKey('ExpectedApplication') -and $instance.Application -ne $ExpectedApplication) {
            $message = "Starr instance '$instanceName' is '$($instance.Application)', not '$ExpectedApplication'."
            $exception = [System.ArgumentException]::new($message, 'Name')
            $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidArgument -ErrorId 'StarrApplicationMismatch' -TargetObject $instanceName -Activity $MyInvocation.MyCommand.Name -RecommendedAction "Specify an instance configured for $ExpectedApplication."

            Invoke-StarrFunctionErrorHandler -Cmdlet $PSCmdlet -ErrorRecord $errorRecord -OriginalErrorAction $originalErrorAction -NoLog
            return
        }

        $Url = $instance.Url
        $ApiKey = $instance.ApiKey
    }
    if (-not $PSBoundParameters.ContainsKey('ApiVersion') -and $resolvedApplication -eq 'Prowlarr') {
        $ApiVersion = 'v1'
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
        $response = Invoke-RestMethod @parameters

        if ($resolvedApplication -eq 'Prowlarr' -and $normalizedEndpoint -match '^(indexer|downloadclient|notification)(/(schema|[0-9]+))?$') {
            $response = @(
                foreach ($provider in $response) {
                    Protect-StarrProviderResource -Resource $provider
                }
            )
        }

        if ($normalizedEndpoint -eq 'log' -and $null -ne $response -and $null -ne $response.PSObject.Properties['records']) {
            foreach ($record in @($response.records)) {
                if ($null -eq $record) {
                    continue
                }

                foreach ($property in $record.PSObject.Properties) {
                    if ($property.Value -is [System.String]) {
                        $property.Value = Protect-StarrSensitiveText -Text $property.Value -SensitiveValue @($ApiKey)
                    }
                }
            }
        }

        foreach ($responseItem in $response) {
            $responseItem
        }
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









