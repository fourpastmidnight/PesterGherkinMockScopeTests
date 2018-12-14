function Get-ParameterValues {
    <#
        .SYNOPSIS
            Get the actual values of parameters which have manually set (non-null) default values or values passed
            in the call

        .DESCRIPTION
            Unlike $PSBoundParameters, the hashtable returned from Get-ParameterValues includes non-empty default
            parameter values. NOTE: Default values that are the same as the implied values are ignored (e.g.: empty
            strings, zero numbers, nulls).

            If the function in which Get-ParameterValues is used has parameters which do not declare a default
            value, if no value is provided for those parameters when the function is called, Get-ParameterValues
            will return a hashtable without keys for those parameters. If the function declares default values for
            parameters which are not decorated with the ValidateNotNull, ValidateNotNullOrEmpty or
            ValidateCollectionNotEmpty attrtibutes and the caller explicitly passes $null into one of these
            parameters, Get-ParameterValues returns a hashtable containing keys for those parameters.

        .LINK
            https://gist.github.com/Jaykul/72f30dce2cca55e8cd73e97670db0b09/

        .LINK
            https://gist.github.com/elovelan/d697882b99d24f1b637c7e7a97f721f2/

        .EXAMPLE
            # Example 1: How Get-ParameterValues works
            PS C:\> $func = "@
            >> function Test {
            >>     [CmdletBinding()]
            >>         param ([string] $Value = $null)
            >>
            >>         $Parameters = Get-ParameterValues
            >>
            >>         $hasKey = $Parameters.ContainsKey('Value')
            >>
            >>         Write-Host "`$Parameters contains key 'Value'? $hasKey"
            >>         Write-Hast "`$Parameters.Value is '$(if ($hasKey -and $null -eq $Parameters.Value) { '$null' } else { $Parameters.Value })'"
            >> }
            >> "@
            PS C:\> Invoke-Expression $func
            PS C:\> Test 5
            $Parameters contains key 'Value'? True
            $Parameters.Value is '5'
            PS C:\> Test $null
            $Parameters contains key 'Value'? True
            $Parameters.Value is ''
            PS C:\> Test
            $Parameters contains key 'Value'? False
            $Parameters.Value is ''.

            The first multi-line command defines a test function named Test in the $func variable.

            The second line adds the Test function to the Function:\ PSDrive.

            The third line call Test with a value of 5. You can see that Get-ParameterValues returned a Parameters
            dictionary containing a key Values with the value 5.

            The fourth line calls Test with a value of $null. Because $null was explicitly specified,
            Get-ParameterValues returned a hashtable with a Value key whose value is $null.

            The fifth line omits any value for the Value parameter. This time, Get-ParameterValues returns a
            hashtable which does not contain a Value key.


    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Scope="Function", Target="*")]
    [OutputType([hashtable])]
    param()

    # The $MyInvocation for the caller
    $Invocation = Get-Variable -Scope 1 -Name MyInvocation -ValueOnly

    # The $PSBoundParameters for the caller
    $BoundParameters = Get-Variable -Scope 1 -Name PSBoundParameters -ValueOnly

    $ParameterValues = @{}
    foreach($parameter in $Invocation.MyCommand.Parameters.GetEnumerator()) {
        try {
            $key = $parameter.Key
            if($null -ne ($value = Get-Variable -Name $key -ValueOnly -ErrorAction Ignore)) {
                if(($null -as $parameter.Value.ParameterType) -ne $value) {
                    $ParameterValues[$key] = $value
                }
            }

            if($BoundParameters.ContainsKey($key)) {
                $ParameterValues[$key] = $BoundParameters[$key]
            }
        } finally { }
    }

    $ParameterValues
}
