# Introduction

This repository contains a MVCE (Minimally Viable and Complete Example) module with Gherkin-style Pester tests
which use mocks for which, when asserting that the mock was called with specified parameters, the parameter test
does not pass no matter how the parameter test is specified when asserting the mock.

## Other Information

This repository is to illustrate the problem as described in issue #1162 for Pester. I wanted to create an entire,
but simplified module, to best represent the environment under which the issue is being experienced, especially
since it appears to be involving PowerShell scoping issues (at least, this is my working hypothesis).

Two things to note, which are expanded on below:
* My original code was running against a customized version of Pester
  * Again, more info below, but the test code still exhibits the same behavior when run against the officially released version.
* There are already defined debug launch configurations for VS Code to help assist with stepping through Pester.

### Customized Pester Dependency

The code was originally developed with a customized version of Pester, located in the Dependencies folder. This version
contains changes for PRs which are open on Pester, including #1142 and #1150, and a fix for issue #1164. There are also
changes to modify the output for Gherkin-style tests that are on my personal fork of Pester which are under development.
However, given these changes are really limited to improving the display of the test run in the console, these changes
_shouldn't_ be affecting how mocks are working in Pester.

Having said that, there is a VS Code launch configuration which explicitly loads the officially released version 4.4.3
of Pester. And running the test code through the official module resulted in the same behavior. So, run any launch
configuration you want which runs the Gherkin tests, but the results should be the same.

### Predifend VS Code Launch Configurations

Here are the relevant launch configurations that can be used to quickly step through the code:
* (Official) PowerShell Pester Tests/Gherkin Scenarios
  * Runs all scenarios (there's only one) using the official v4.4.3 Pester module
* (Official) PowerShell Pester Gherkin Scenarios w/ Scenario Name(s) Prompt
  * Allows you to specify the scenario(s) to run using the official v4.4.3 Pester module
* (Custom) PowerShell Pester Tests/Gherkin Scenarios
  * Runs all scenarios using the included customized v4.4.3 Pester module
* (Custom) PowerShell Pester Gherkin Scenarios w/ Scenario Name(s) Prompt
  * Allows you to specify the scenario(s) to run using the included custom v4.4.3 Pester module

### My Current Environment

Using the official module:

> Pester version : 4.4.3 C:\Program Files\WindowsPowerShell\Modules\Pester\4.4.3\Pester.psd1\
> PowerShell version : 5.1.17134.165\
> OS version : Microsoft Windows NT 10.0.17134.0\
> VS Code Insiders v1.31\
> VS Code v1.30

Using my custom module:

> Pester version : 4.4.3.1 C:\src\git\Experiments\PesterGherkinMocScopeTests\Dependencies\Pester\4.4.3.1\Pester.psd1\
> PowerShell version : 5.1.17134.165\
> OS version : Microsoft Windows NT 10.0.17134.0\
> VS Code Insiders v1.31\
> VS Code v1.30
