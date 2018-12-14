Given "the following query options:?" {
    param([hashtable[]]$Table)

    # $Script:Context is being used similarly to 'world' in Ruby's cucumber.
    if (!$Script:Context) {
        $Script:Context = @{}
    }

    $Script:Context.GetVraResourceParameters = @(foreach ($row in $Table) {
        $params = @{
            ManagedOnly = (ConvertFrom-TableCellValue $row.ManagedOnly) -as [switch]
            WithExtendedData = (ConvertFrom-TableCellValue $row.WithExtendedData) -as [switch]
            WithOperations = (ConvertFrom-TableCellValue $row.WithOperations) -as [switch]
        }

        foreach ($key in $params.Keys.Clone()) {
            if ($null -eq $params[$key]) {
                $params.Remove($key)
            }
        }

        $params
    })
}

When "Get-vRAResource is invoked with the given parameters" {
    $Script:Context.ParameterFilterClosure = {
        param ([Uri]$ExpectedApiUriSegment)

        # I probably don't need to do this, but following an example at
        # https://blogs.technet.microsoft.com/heyscriptingguy/2013/04/05/closures-in-powershell/
        $_ExpectedApiUriSegment = $ExpectedApiUriSegment

        {
            if ("$ApiUriSegment" -ieq "$_ExpectedApiUriSegment") {
                $true
            } else {
                Write-Host "This mock will not be executed because the 'ApiUriSegment' parameter did not have the expected value:"
                Write-Host "   Expected: $_ExpectedApiUriSegment"
                Write-Host "   Actual:   $ApiUriSegment"
                $false
            }
        }.GetNewClosure()
    }
}

Then "the (?i:URL) generated for the search query should be:?" {
    param([hashtable[]]$Table)

    # Invoke-vRARestMethod is called from Get-vRAResource, so need to use -ModuleName parameter
    # since Invoke-vRARestMethod is invoked within the context of the module itself.
    Mock Invoke-vRARestMethod -ModuleName 'PesterGherkinMockScopeTests'

    $Table.Length | Should -BeExactly $Script:Context.GetVraResourceParameters.Length

    # Looping through a) the parameters to be passed to Get-vRAResource, and the expected generated Url segment
    for ($n = 0; $n -lt $Table.Length; $n++) {
        $params = $Script:Context.GetVraResourceParameters[$n]
        try {
            Get-VraResource -vRASession $Script:Context.vRASession @params

            # Create a relative Uri with the expected generated Api segment.
            $ExpectedUriApiSegment = [Uri]::new([Uri]::EscapeUriString($Table[$n].UrlSubstring), [UriKind]::Relative)

            # This should be the simplest thing I need to do to assert this mock was called
            Assert-MockCalled Invoke-vRARestMethod -ModuleName PesterGherkinMockScopeTests -ParameterFilter { "$ApiUriSegment" -ieq "$ExpectedUriApiSegment" }

            # This should also work, I think..., but shouldn't be required
            #----------------------------------------------------------------------------------------------
            #Assert-MockCalled Invoke-vRARestMethod -ModuleName PesterGherkinMockScopeTests -ParameterFilter { "$ApiUriSegment" -ieq "$ExpectedUriApiSegment" } -Scope 0 #<-- This is current scope, right?

            # And, after fixing Pester issue #1164, this should also work, but again, shouldn't be required:
            #-----------------------------------------------------------------------------------------------
            #Assert-MockCalled Invoke-vRARestMethod -ModuleName PesterGherkinMockScopeTests -ParameterFilter { "$ApiUriSegment" -ieq "$ExpectedUriApiSegment" } -Scope Scenario

            # Since none of the above worked, now we use what we did in the When block above, to generate
            # a script block containing the parameter filter test, as a closure, in the hopes that the local variable
            # passed into the closure is captured, and now local to the closure itself, and therefore available to
            # the parameter filter test script block.
            #
            # BUT, the scope will not contain either the local variable $ExpectedApiUriSegment above, nor the
            # local variable inside the closure, $_ExpectedApiUriSegment.
            #-----------------------------------------------------------------------------------------------
            #$parameterFilter = &$Script:Context.ParameterFilterClosure $ExpectedUriApiSegment
            #Assert-MockCalled 'Invoke-vRARestMethod' -ModuleName 'PesterGherkinMockScopeTests' -ParameterFilter $parameterFilter

            # And once again, you could try scoping the same call above, but nothing changes
            #----------------------------------------------------------------------------------------------
            #Assert-MockCalled 'Invoke-vRARestMethod' -ModuleName 'PesterGherkinMockScopeTests' -ParameterFilter $parameterFilter -Scope 0
            #Assert-MockCalled 'Invoke-vRARestMethod' -ModuleName 'PesterGherkinMockScopeTests' -ParameterFilter $parameterFilter -Scope Scenario # <-- Need to fix #1164 for this to work...

        } catch {
            # Catching the exception thrown by Assert-MockCalled so I can get _useful_ output... :|
            if ($_.Exception) {
                $message = $_.Exception.Message.Trim();
                if ($message.StartsWith("Expected Invoke-vRARestMethod")) {
                    $message = "Expected Invoke-vRARestMethod in module PesterGherkinMockScopeTests to be called with '$([Uri]::EscapeUriString($Table[$n].UrlSubstring))'."
                    throw [Exception]::new($message, $_.Exception)
                } else {
                    throw
                }
            } else {
                throw
            }
        }
    }
}
