BeforeEachFeature {
    Import-Module -Name "${pwd}\PesterGherkinMockScopeTests\PesterGherkinMockScopeTests.psd1" -Scope Global -Force

    filter global:ConvertFrom-TableCellValue {
        Param(
            [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
            [AllowNull()]
            [AllowEmptyString()]
            $Value
        )

        Process {
            if ($Value -eq '$null') {
                $Value = $null
            }

            switch -Regex ($Value) {
                '^"?\{\s*(?<ScriptBody>.*)\s*\}"?$'   { $Value = [ScriptBlock]::Create($Matches.ScriptBody) }
                '"(?<StringValue>.*)"'                { $Value = ($Matches.StringValue -as [string]) }
                '$?(?i:(?<Boolean>true|false))'       { $Value = [Boolean]::Parse($Matches.Boolean) }
                '^\d+$'                               { $Value = $Value -as [int] }
                default                               {  }
            }

            $Value
        }
    }
}

AfterEachFeature {
    $Module = Get-Module -Name "PesterGherkinMockScopeTests"
    if ($Module) {
        $Module.Name | Remove-Module
    }

    if (Test-Path "Function:\global:ConvertTo-Parameter") {
        Remove-Item Function:\global:ConvertTo-Parameter
    }
}
