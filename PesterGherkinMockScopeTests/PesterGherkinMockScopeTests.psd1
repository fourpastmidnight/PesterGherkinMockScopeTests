﻿#
# Module manifest for module 'PesterGherkinMockScopeTests'
#
# Generated by: Craig Shea
#
# Generated on: 11/7/2018
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'PesterGherkinMockScopeTests.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID = ''

    # Author of this module
    Author = 'Craig Shea'

    # Company or vendor of this module
    CompanyName = ''

    # Copyright statement for this module
    Copyright = ''

    # Description of the functionality provided by this module
    Description = 'MVCE for exploring Pester Gherkin Mock scoping issues'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    DotNetFrameworkVersion = '4.6.1'

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    CLRVersion = '4.0'

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @('.\PesterGherkinMockScopeTests.types.ps1xml')

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @('.\PesterGherkinMockScopeTests.format.ps1xml')

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('Get-vRAResource','Invoke-vRARestMethod','New-vRASession','Remove-vRASession')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            Author = 'Craig Shea'
            Owners = 'Craig Shea'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/fourpastmidnight/PesterGherkinMockScopeTests'
            Repository = 'https://github.com/fourpastmidnight/PesterGherkinMockScopeTests'

            # A URL to an icon representing this module.
            #IconUri = ''

            # A URL to the license for this module.
            #LicenseUri = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update
            RequireLicenseAcceptance = $false

            # ReleaseNotes of this module
            ReleaseNotes = @"
#### Changelog

##### v0.1.0

* Initial module release
"@
            # Prerelease string of this module
            # Prerelease = ''

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Test','Pester','Mocking')

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

