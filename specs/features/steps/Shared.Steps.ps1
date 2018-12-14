When "'(?<CmdletName>.*)' is invoked" {
    [CmdletBinding()]
    Param ([string]$CmdletName)

    Write-Debug "Cmdlet: $CmdletName"
    Write-Debug "Context: $($Script:Context | ConvertTo-JSON)"

    $Script:Context.Add('Actual', (&$CmdletName @Script:Context))

    Write-Debug $Script:Context.Actual.GetType().FullName
}

GherkinStep "the result is formatted as a (table|(wide )?list|custom view)" {
    Param([string]$FormatType)

    switch -Regex ($FormatType) {
        "table"       { $formatted = $Script:Context.Actual | Format-Table  | Out-String }
        "list"        { $formatted = $Script:Context.Actual | Format-List   | Out-String }
        "(wide )list" { $formatted = $Script:Context.Actual | Format-Wide   | Out-String }
        "custom view" { $formatted = $Script:Context.Actual | Format-Custom | Out-String }
    }

    $Script:Context.Remove('Actual')
    $Script:Context.Actual = $formatted
    Remove-Variable formatted
}

Then "it should be displayed as:?" {
    Param([string]$ExpectedResult)

    $Script:Context.Actual | Should -BeExactly $ExpectedResult
}
