@{
    Severity=@(
        "Warning",
        "Error"
    )

    IncludeRules = @(
        'PSUseCompatibleCmdlets',

        # Code Formatting Rules
        'PSPlaceOpenBrace',
        'PSPlaceCloseBrace',
        'PSUseConsistentIndentation',
        'PSUseWhitespace',

        # PSGallery Rules (includes Cmdlet Design rules)
        'PSUseApprovedVerbs',
        'PSReservedCmdletChar',
        'PSReservedParams',
        'PSShouldProcess',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns',
        'PSMissingModuleManifestField',
        'PSAvoidDefaultValueSwitchParameter',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingWMICmdlet',
        'PSAvoidUsingEmptyCatchBlock',
        'PSUseCmdletCorrectly',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidGlobalVars',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingComputerNameHardcoded',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSUsePSCredentialType',
        'PSAvoidUsingUserNameAndPasswordParams',
        'PSAvoidUsingFilePath',
        'PSDSC*'
    )

    Rules = @{
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
        }

        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $false
        }

        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
        }

        PSUseWhitespace = @{
            Enable = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckSeparator = $true
        }

        # https://github.com/PowerShell/PSScriptAnalyzer/blob/260a573e5e3f1ce8580c6ceb6f9089c7f1aadbc6/RuleDocumentation/UseCompatibleCmdlets.md
        PSUseCompatibleCmdlets = @{Compatibility = @(
            "core-6.0.0-alpha-linux",
            "core-6.0.0-alpha-windows",
            "core-6.0.0-alpha-osx"
        )}
    }

}
