function Get-vRAResource {
    <#
        .SYNOPSIS
        Get a deployed resource

        .DESCRIPTION
        A deployment represents a collection of deployed artifacts that have been provisioned by a provider.

        .PARAMETER WithExtendedData
        Populate the resources extended data by calling their provider

        .PARAMETER WithOperations
        Populate the resources operations attribute by calling the provider. This will force withExtendedData to true.

        .PARAMETER ManagedOnly
        Show resources owned by the users managed business groups, excluding any machines owned by the user in a non-managed
        business group

        .INPUTS
        None

        .OUTPUTS
        None

        .EXAMPLE
        Get-vRAResource -vRASession $vRASession

        .EXAMPLE
        Get-vRAResource -vRASession $vRASession -WithExtendedData

        .EXAMPLE
        Get-vRAResource -vRASession $vRASession -WithOperations

        .EXAMPLE
        Get-vRAResource -vRASession $vRASession -ManagedOnly

        .EXAMPLE
        Get-vRAResource -vRASession $vRASession -WithOperations -ManagedOnly

    #>
    [CmdletBinding()]
    Param (
        [Alias('-vra-session', 'Session', 's')]
        [PSTypeName('vRASession')]
        $vRASession,

        [switch]$ManagedOnly,
        [switch]$WithExtendedData,
        [switch]$WithOperations
    )

    Process {
        try {
            $ApiUriSegment = "/catalog-service/api/consumer/resourceViews"

            [string[]]$QueryOptions = @()
            if ($ManagedOnly) {
                $QueryOptions += @("managedOnly=true")
            }

            # Specifying 'withOperations=true' in the Url query string also brings back
            # the extended data, so no need to set both query parameters.
            if ($WithOperations) {
                $QueryOptions += @("withOperations=true")
            } elseif ($WithExtendedData) {
                $QueryOptions += @("withExtendedData=true")
            }

            $UriQueryString = ($QueryOptions -join '&').Trim('&')
            if ($UriQueryString) {
                $UriQueryString = "?${UriQueryString}"
            }

            try {
                $Response = Invoke-vRARestMethod -vRASession $vRASession -Method GET -ApiUriSegment "${ApiUriSegment}$([Uri]::EscapeUriString($UriQueryString))" -Verbose:$VerbosePreference

                # This is here just to make PSScriptAnalyzer happy--not really relevant to what's being tested.
                $Response
            } catch {
                throw [Exception]::new("An error occurred while getting the requested vRA Resources. See the inner exception for more details.", $_.Exception)
            }
        } catch {
            throw $_
        }
    }
}
