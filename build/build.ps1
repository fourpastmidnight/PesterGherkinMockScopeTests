#Requires -Version 4

<#
    .SYNOPSIS
    A wrapper script for build.psake.ps1

    .DESCRIPTION
    This script is a wrapper for the processes defined in build.psake.ps1.

    .PARAMETER Task
    The build task that needs to be executed.

    .PARAMETER Properties
    Properties that are to be passed to psake to be used during execution of the selected build task

    .PARAMETER Parameters
    Parameters that are to be passed to psake to be used during the execution of the selected build task

    .PARAMETER EnableExit
    Will cause this script to exit with a non-zero exit code if the selected Task completes unsuccessfully.
    Do not use this in VS Code, for example, as it will cause the shell in your terminal window to terminate.

    .INPUTS
    System.String

    .OUTPUTS
    None

    .EXAMPLE
    .\build.ps1

    .Example
    .\build.ps1 -Task Build
#>

[Cmdletbinding()]
Param (
    [Parameter()]
    [ValidateSet("Init", "Test", "Analyze", "Build", "UpdateModuleManifest", "UpdateDocumentation")]
    [String[]]$Task = "Test",
    [hashtable]$Properties,
    [hashtable]$Parameters,
    [switch]$EnableExit
)

Set-StrictMode -Version 'Latest'

# Install PSDepend if it's not already installed
if (!(Get-Module -Name PSDepend -ListAvailable)) {
    Install-Module -Name PSDepend -Scope CurrentUser -Force
}
Import-Module -Name PSDepend

# Install dependencies
$null = Invoke-PSDepend -Path "${PSScriptRoot}\build.depend.psd1" -Install -Import -Force

# Set Build Environment
Set-BuildEnvironment -Force

# Set Psake parameters
$PsakeBuildParameters = @{
    BuildFile = "${PSScriptRoot}\build.psake.ps1"
    TaskList = $Task
}

if ($PSBoundParameters.ContainsKey('Properties')) {
    $PsakeBuildParameters.Properties = $PSBoundParameters['Properties']
}

if ($PSBoundParameters.ContainsKey('Parameters')) {
    $PsakeBuildParameters.Parameters = $PSBoundParameters['Parameters']
}

# Start Build
Invoke-Psake @PsakeBuildParameters -Verbose:$VerbosePreference
Write-Host ""
if ($EnableExit) {
    exit ([int](-not $psake.build_success))
}

Remove-Item Env:\BH*
Remove-Module BuildHelpers
