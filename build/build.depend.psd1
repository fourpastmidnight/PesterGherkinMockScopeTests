@{
    PSDependOptions = @{
        Target = '$ENV:USERPROFILE\Documents\WindowsPowerShell\Modules'
    }

    BuildHelpers =    @{
        Name = 'BuildHelpers'
        DependencyType = 'PSGalleryModule'
        Version = 'latest'
    }

    PSScriptAnalyzer = @{
        Name = 'PSScriptAnalyzer'
        DependencyType = 'PSGalleryModule'
        Version = 'latest'
    }

    # TODO: Uncomment this when issue #1142 is resolved. For now, use our own modified version in .\Dependencies
    # Pester       =  @{
    #     Name = 'Pester'
    #     DependencyType = 'PSGalleryModule'
    #     Version = 'latest'
    # }

    platyPS = @{
        Name = 'platyPS'
        DependencyType = 'PSGalleryModule'
        Version = 'latest'
    }

    psake        =    @{
        Name = 'psake'
        DependencyType = 'PSGalleryModule'
        Version = 'latest'
    }
}
