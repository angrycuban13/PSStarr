function Resolve-StarrTagId {
    <#
    .SYNOPSIS
        Resolves an exact tag label to its resource identifier.

    .DESCRIPTION
        This function retrieves application tags and resolves one case-insensitive exact label match. Missing and ambiguous labels produce structured error records before any write occurs.

    .PARAMETER InstanceName
        The saved instance name used to retrieve tags.

    .PARAMETER Url
        The explicit Starr application URL used to retrieve tags.

    .PARAMETER ApiKey
        The API key paired with an explicit URL.

    .PARAMETER Application
        The expected application type used for validation and API-version selection.

    .PARAMETER TagName
        The exact tag label to resolve.

    .EXAMPLE
        Resolve-StarrTagId -InstanceName Main -Application Radarr -TagName reviewed

    .INPUTS
        None.

        You cannot pipe objects to this function.

    .OUTPUTS
        [System.Int32]

        This function returns the positive identifier of the matching tag.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Named')]
    [OutputType([System.Int32])]
    param(
        [Parameter(ParameterSetName = 'Named')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateScript({ Test-StarrUrl -Url $_ })]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $ApiKey,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Radarr', 'Sonarr', 'Prowlarr')]
        [System.String]
        $Application,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [System.String]
        $TagName
    )

    $request = @{}

    if ($PSBoundParameters.ContainsKey('Application')) {
        $request.Application = $Application
    }

    if ($PSCmdlet.ParameterSetName -eq 'Explicit') {
        $request.Url = $Url
        $request.ApiKey = $ApiKey
    }
    elseif ($PSBoundParameters.ContainsKey('InstanceName')) {
        $request.InstanceName = $InstanceName
    }

    $tagMatches = @(
        Get-StarrTag @request | Where-Object {
            $_.label -ieq $TagName
        }
    )

    if ($tagMatches.Count -eq 0) {
        $applicationLabel = if ($PSBoundParameters.ContainsKey('Application')) {
            $Application
        }
        else {
            'the Starr application'
        }

        $exception = [System.Management.Automation.ItemNotFoundException]::new("Tag '$TagName' was not found in $applicationLabel.")
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category ObjectNotFound -ErrorId 'StarrTagNotFound' -TargetObject $TagName -Activity $MyInvocation.MyCommand.Name -RecommendedAction 'Specify an existing exact tag name or use TagId.'

        throw $errorRecord
    }

    if ($tagMatches.Count -gt 1) {
        $applicationLabel = if ($PSBoundParameters.ContainsKey('Application')) {
            $Application
        }
        else {
            'the Starr application'
        }

        $exception = [System.IO.InvalidDataException]::new("Tag name '$TagName' matched multiple tags in $applicationLabel.")
        $errorRecord = New-StarrErrorRecord -Exception $exception -Category InvalidData -ErrorId 'StarrTagNameAmbiguous' -TargetObject $TagName -Activity $MyInvocation.MyCommand.Name -RecommendedAction 'Use TagId to select one tag explicitly.'

        throw $errorRecord
    }

    [System.Int32] $tagMatches[0].id
}
