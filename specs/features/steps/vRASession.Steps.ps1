GherkinStep "a new vRA session is requested via the '(?<ParameterSetName>Credential|Username)' parameter set" {
    param([string]$ParameterSetName)
    # It's necessary to convert the DateTimeOffset to a string and parse it back to a
    # DateTimeOffset in order to control the precision of the actual Expected
    # DateTimeOffset. The vRA API returns fractional seconds only up to 3 decimal
    # places.
    $Script:Context.RequestDate = [DateTimeOffset]::new(2018, 11, 29, 12, 28, 26, 832, [TimeSpan]::Zero)

    # Need to explicitly calculate this here, instead of "inline" in the Hashtable in the MockWith
    # parameter to Mock because otherwise, the expression itself is sent to the Mock and it doesn't
    # have access to $Script:Context, which causes the mock to fail with a RemoteExecutionException
    # due to an inner NullReferenceException.
    # In addition, this variable must be made Global so that when it is finally evaluated within the
    # mock, the mock can access it.
    $Global:expiry = $Script:Context.RequestDate.AddHours(24.0).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')

    Mock -ModuleName 'PesterGherkinMockScopeTests' -CommandName Invoke-RestMethod -ParameterFilter {
        $Body -and ($Body | ConvertFrom-JSON).tenant -eq 'the-tenant'
    } -MockWith {
        @{
            expires = $Global:expiry
            id = 'the-token'
            tenant = 'the-tenant'
        } | ConvertTo-JSON
    }

    $new_vRASessionParams = @{
        Tenant = $Script:Context.Tenant
        vRAServer = $Script:Context.vRAServerFQDN
        RetrieveApiVersion = $False
    }

    if ($ParameterSetName -eq 'Credential') {
        $new_vRASessionParams.Credential = $Script:Context.Credential
    } elseif ($ParameterSetName -eq 'Username') {
        $new_vRASessionParams.Username = $Script:Context.Credential.GetNetworkCredential().Username
        $new_vRASessionParams.Password = $Script:Context.Credential.Password
    }

    $Script:Context.Actual = New-vRASession @new_vRASessionParams

    # Clean up the global variable!
    Remove-Variable expiry -Scope Global
}

GherkinStep "an authorized REST API user has authenticated with vRA" {
    if (!$Script:Context) {
        $Script:Context = @{}
    }

    $Script:Context.vRAServerFQDN = 'vra.mycompany.com'
    $Script:Context.Credential = [PSCredential]::new('a-user', ('a-password' | ConvertTo-SecureString -AsPlainText -Force))
    $Script:Context.Tenant = 'the-tenant'
    $step = Find-GherkinStep -Step "When a new vRA session is requested via the 'Credential' parameter set"

    Invoke-Command $step.Implementation -ArgumentList 'Credential'
    $vRASession = $Script:Context.Actual
    $Script:Context = @{}
    $Script:Context.vRASession = $vRASession
}

GherkinStep "the authorized REST API user has authenticated with vRA" {
    $step = Find-GherkinStep -Step "When a new vRA session is requested via the 'Credential' parameter set"

    Invoke-Command $step.Implementation -ArgumentList 'Credential'
}
