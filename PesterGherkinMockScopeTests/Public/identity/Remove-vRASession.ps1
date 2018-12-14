function Remove-vRASession {
    [CmdletBinding()]
    # This function doesn't actually modify system state, so this rule can be safely ignored.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [Alias('-vra-session', 'Session', 's')]
        [ref]$vRASession
    )

    end {
        if ($vRASession.Value.PSObject.TypeNames -notcontains 'vRASession') {
            throw [ArgumentException]::new("Expected a reference to a PSCustomObject containing a PSTypeName 'vRASession'", 'vRASession')
        }

        $deleteBearerTokenRequestParams = @{
            Uri = [Uri]::new($vRASession.Value.ServerUri, "identity/api/tokens/$($vRASession.Value.Token)")
            Method = 'DELETE'
            Headers = @{
                Accept = 'application/json'
                Authorization = "Bearer $($vRASession.Value.Token)"
                'Cache-Control' = 'no-cache'
            }
            ContentType = 'application/json'
        }

        try {
            Invoke-RestMethod @deleteBearerTokenRequestParams
        } catch {
            throw [Exception]::new("An error occurred while deleting the session. The session has been closed and no further action is required. See the inner exception for more information.", $responseError.ErrorRecord.Exception)
        } finally {
            $vRASession.Value = $null
        }
    }
}
