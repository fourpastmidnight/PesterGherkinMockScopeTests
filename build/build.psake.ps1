# Dot source build.settings.ps1
. $PSScriptRoot\build.settings.ps1

# Add any parameters from build.ps1
Properties {
    $divider = '-'*70
}

# Define the build tasks
Task Default -depends Build
Task Test -depends Analyze, ExecuteTest
Task Analyze -depends Init, ExecuteAnalyze
Task UpdateModuleManifest -depends Init, UpdateModuleExportedFunctions, UpdateModuleFormatsToProcess, UpdateModuleTypesToProcess
Task Build -depends Init, ExecuteAnalyze, ExecuteTest, UpdateModuleManifest, GenerateModuleHelp, CreateArtifact, CreateArchive

#################
# Task: Init    #
#################
Task Init {
    Write-Output $divider
    Write-Output "Build System Details:"
    foreach ($Item in (Get-Item -Path ENV:BH*)){
        Write-Output "$($Item.Name): $($Item.Value)"
    }

    Write-Host ""
}

#################
# Task: Analyze #
#################

Task ExecuteAnalyze {
    Write-Output $divider
    Write-Output "ScriptAnalyzerSeverityLevel: $($PSScriptAnalyzerFailBuildOnSeverityLevel)"
    $Results = Invoke-ScriptAnalyzer -Path $ENV:BHModulePath -Recurse -Settings $PSScriptAnalyzerSettingsPath -Verbose:$VerbosePreference
    $Results | Select-Object RuleName, Severity, ScriptName, Line, Message | Format-List

    if ($Results -and !(Test-Path -Path $PSScriptAnalyzerArtifactsPath)) {
        New-item -ItemType Directory -Path $PSScriptAnalyzerArtifactsPath
        $Results | ConvertTo-JSON | Set-Content (Join-Path $PSScriptAnalyzerArtifactsPath "ScriptAnalysis_PS${PSVersion}.json")
    }

    switch ($PSScriptAnalyzerFailBuildOnSeverityLevel) {
        'None' {
            return
        }
        'Error' {
            Assert -conditionToCheck (
                ($Results | Where-Object Severity -eq 'Error').Count -eq 0
                ) -failureMessage 'One or more PSScriptAnalyzer errors were found.'
        }
        'Warning' {
            Assert -conditionToCheck (
                ($Results | Where-Object {
                    $_.Severity -eq 'Warning' -or $_.Severity -eq 'Error'
                }).Count -eq 0) -failureMessage 'One or more PSScriptAnalyzer warnings were found.'
        }
        default {
            Assert -conditionToCheck ($Result.Count -eq 0) -failureMessage 'One or more PSScriptAnalyzer issues were found.'
        }
    }

    Write-Host ""
} -PreAction {
    if (!(Test-Path $PSScriptAnalyzerArtifactsPath)) {
        Remove-Item -Path $PesterTestArtifactsPath -Recurse -Confirm:$False -Force
    }
}

##############
# Task: Test #
##############

# TODO: Remove PreAction and PostAction script blocks once Pester issue #1129 is closed
Task ExecuteTest -Action {
    Write-Output $divider

    New-Item -ItemType Directory -Path $PesterTestArtifactsPath | Out-Null

    if (!([IO.Path]::IsPathRooted($PesterTestScripts))) {
        $PesterTestScripts = Join-Path $ENV:BHProjectPath $PesterTestScripts
    }

    $Parameters = @{
        Path = $PesterTestScripts
        OutputFormat = $PesterOutputFormat
        OutputFile = (Join-Path $PesterTestArtifactsPath $PesterTestResultsFilename)
        PesterOption = (New-PesterOption -TestSuiteName $PesterTestSuiteName -IncludeVSCodeMarker:$PesterIncludeVSCodeMarker)
        EnableExit = $PesterEnableExit
        Strict = $PesterStrict
        Show = $PesterShow
        PassThru = $PesterPassThru
        Verbose = $VerbosePreference
        Debug = $DebugPreference
    }

    if ($null -ne $PesterScenarios -and $PesterScenarios.Length -gt 0) {
        $Parameters.ScenarioName = @($PesterScenarios)
    }

    if ($null -ne $PesterTags -and $PesterTags.Length -gt 0) {
        $Parameters.Tag = @($PesterTags)
    }

    if ($null -ne $PesterExcludeTags -and $PesterExcludeTags.Length -gt 0) {
        $Parameters.ExcludeTag = @($PesterExcludeTags)
    }

    if ($null -ne $PesterCodeCoverage) {
        if ($PesterCodeCoverage -is [hashtable]) {
            $Parameters.CodeCoverage = $PesterCodeCoverage
        } elseif ($PesterCodeCoverage -is [string[]]) {
            $Parameters.CodeCoverage = @($PesterCodeCoverage)
        } else {
            Write-Host "WARNING: `$PesterCodeCoverage must be a string[] or a hashtable (IDictionary)" -ForegroundColor Yellow
        }
    }

    Push-Location
    Set-Location -Path $ENV:BHProjectPath
    $TestResults = Invoke-Gherkin @Parameters
    Pop-Location

    if ($TestResults -and $TestResults.FailedCount -gt 0) {
        $TestResults | Format-List
        Write-Error -Message "Failed '$($TestResults.FailedCount)' tests."
    }

    Write-Host ""
} -PreAction {
    Import-Module -Name "${ENV:BHProjectPath}\Dependencies\Pester\4.4.3.1\Pester.psd1" -Global -Force

    if (Test-Path $PesterTestArtifactsPath) {
        Remove-Item -Path $PesterTestArtifactsPath -Confirm:$False -Force -Recurse
    }
} -PostAction {
    Remove-Module -Name 'Pester'
}

###############
# Task: Build #
###############

Task UpdateModuleExportedFunctions {
    Write-Output $divider
    $PublicFunctions = Get-ChildItem -Path "$($ENV:BHModulePath)\Public" -Filter "*.ps1" -Recurse | Sort-Object

    $ExportFunctions = @()

    foreach ($FunctionFile in $PublicFunctions) {
        $AST = [System.Management.Automation.Language.Parser]::ParseFile($FunctionFile.FullName, [ref]$null, [ref]$null)
        $Functions = $AST.FindAll({
            # Only export functions that contain a "-" and do not start with "int"
            $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and `
            $args[0].Name -match "-" -and `
            !$args[0].Name.StartsWith("int")
        }, $true)

        if ($Functions.Name) {
            $ExportFunctions += $Functions.Name
        }
    }

    Set-ModuleFunctions -Name $ENV:BHPSModuleManifest -FunctionsToExport $ExportFunctions -Verbose:$VerbosePreference

    Write-Host ""
}

Task UpdateModuleFormatsToProcess {
    Write-Output $divider
    [string[]]$FormatsToProcess = @(Get-ChildItem -Path "${ENV:BHModulePath}" -Filter "*.format.ps1xml" -Recurse |
        Select-Object -ExpandProperty FullName |
        ForEach-Object { $_.Replace("${ENV:BHModulePath}", ".") } |
        Sort-Object)

    if ($FormatsToProcess.Length -gt 0) {
        Set-ModuleFormats -Name $ENV:BHPSModuleManifest -FormatsToProcess $FormatsToProcess -Verbose:$VerbosePreference
    }

    Write-Host ""
}

Task UpdateModuleTypesToProcess {
    Write-Output $divider

    [string[]]$TypesToProcess = @(Get-ChildItem -Path "${ENV:BHModulePath}" -Filter "*.types.ps1xml" -Recurse |
        Select-Object -ExpandProperty FullName |
        Foreach-Object { $_.Replace("${ENV:BHModulePath}", ".") } |
        Sort-Object)

    if ($TypesToProcess.Length -gt 0) {
        Set-ModuleTypes -Name $ENV:BHPSModuleManifest -TypesToProcess $TypesToProcess -Verbose:$VerbosePreference
    }

    Write-Host ""
}

Task GenerateModuleHelp {
    [string[]]$helpDocs = @(Get-ChildItem $DocsDirectory -File -Filter "*.md" -Recurse | Select-Object -ExpandProperty FullName)

    New-ExternalHelp -Path $helpDocs -OutputPath "${ENV:BHPSModulePath}\en-US"
}
