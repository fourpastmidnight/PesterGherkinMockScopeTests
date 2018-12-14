##########################
# PSake build properties #
##########################

Properties {

    # ----------------- General -------------------------------------
        $PSVersion = $PSVersionTable.PSVersion.Major
        $ArtifactsPath = "${ENV:BHProjectPath}\artifacts"
        $DocsDirectory = "$ENV:BHProjectPath\docs"
        $ModuleName = "PesterGherkinMockScopeTests"
        $ModuleAuthor = "Craig Shea"
        $ReleaseDirectoryPath = "$($ENV:BHProjectPath)\Release\$($ModuleName)"
        $ModuleManifestVersion = "0.0.0"

    # ----------------- Script Analyzer ------------------------------
        # Should be Warning by default. Can be overridden on demand by using
        # !PSSAError in your commit message
        [ValidateSet('Error', 'Warning', 'Any', 'None')]
        $PSScriptAnalyzerFailBuildOnSeverityLevel = 'Warning'
        $PSScriptAnalyzerArtifactsPath = (Join-Path $ArtifactsPath "PSScriptAnalyzer")
        $PSScriptAnalyzerSettingsPath = "$PSScriptRoot\PSScriptAnalyzerSettings.psd1"

    # ----------------- Pester ---------------------------------------
        $PesterTestArtifactsPath = (Join-Path $ArtifactsPath "TestResults")
        $PesterTestResultsFilename = "TestResult_PS${PSVersion}.xml"
        $PesterTestScripts = "${ENV:BHProjectPath}\specs\features"
        $PesterTestSuiteName = 'PesterGherkinMockScopeTests'
        $PesterIncludeVSCodeMarker = $True
        $PesterScenarios = [string[]]$null
        $PesterTags = [string[]]$null
        $PesterExcludeTags = [string[]]$null
        $PesterCodeCoverage = $null
        $PesterOutputFormat = 'NUnitXml'
        $PesterEnableExit = $False
        $PesterStrict = $False
        $PesterShow = 'All'
        $PesterPassThru = $True

    # ----------------- GitHub ---------------------------------------
        $OrgName = ""
        $RepositoryName = "PesterGherkinMockScopeTests.git"
        $RepositoryUrl = "https://github.com/fourpastmidnight/PesterGherkinMockScopeTests"
    }
