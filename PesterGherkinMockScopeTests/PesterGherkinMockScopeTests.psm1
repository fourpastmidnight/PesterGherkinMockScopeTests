#Requires -Version 4
Set-StrictMode -Version Latest

# Set some module level variables to help determine whether we're on Desktop PowerShell, or PowerShell Core.
if ($PSVersionTable.PSEdition -eq 'Desktop') {
    $Script:IsCoreCLR = $False
    $Script:IsWindows = $True
    $Script:IsLinux = $False
    $Script:IsMacOS = $False
}

$ModuleRoot = $PSScriptRoot
$Public = @( Get-ChildItem -Path $ModuleRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $ModuleRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Classes = @( Get-ChildItem -Path $ModuleRoot\Classes\*.ps1 -Recurse -ErrorAction SilentlyContinue )
Write-Verbose "Importing Functions"

# Import everything in sub folders folder
foreach ( $import in @( $Public + $Private + $Classes ) ) {
    try {
        . $import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

if ($Public.Length -gt 0) {
    # $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($PublicFunction)

    # # Support DEPRECATED functions. Ensure that we are exporting only the function name
    # $DepricatedKeyword = "DEPRECATED-"
    # if ($BaseName.StartsWith($DepricatedKeyword)) {

    #     $BaseName = $BaseName.Trim($DepricatedKeyword)
    # }

    Export-ModuleMember -Function ($Public.BaseName -replace "DEPRECATED-","") -Alias *
}
