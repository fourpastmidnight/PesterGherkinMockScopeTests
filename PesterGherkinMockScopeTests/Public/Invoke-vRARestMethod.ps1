function Invoke-vRARestMethod {
    [CmdletBinding(DefaultParameterSetName = 'Standard')]
    param (
        [Parameter(Mandatory = $True, Position = 0, ParameterSetName="Standard")]
        [Parameter(Mandatory = $True, Position = 0, ParameterSetName="Body")]
        [Parameter(Mandatory = $True, Position = 0, ParameterSetName="OutFile")]
        [PSTypeName('vRASession')]
        [PSCustomObject]$vRASession,

        [Parameter(Mandatory = $True, Position = 1, ParameterSetName="Standard")]
        [Parameter(Mandatory = $True, Position = 1, ParameterSetName="Body")]
        [Parameter(Mandatory = $True, Position = 1, ParameterSetName="OutFile")]
        [ValidateSet("DELETE","GET","HEAD","POST","PUT")]
        [string]$Method,

        [Parameter(Mandatory = $True, Position = 2, ParameterSetName="Standard")]
        [Parameter(Mandatory = $True, Position = 2, ParameterSetName="Body")]
        [Parameter(Mandatory = $True, Position = 2, ParameterSetName="OutFile")]
        [ValidateNotNull()]
        [Uri]$ApiUriSegment,

        [Parameter(Mandatory = $False, Position = 3, ParameterSetName="Standard")]
        [Parameter(Mandatory = $False, Position = 3, ParameterSetName="Body")]
        [Parameter(Mandatory = $False, Position = 3, ParameterSetName="OutFile")]
        [ValidateNotNullOrEmpty()]
        [Collections.IDictionary]$Headers,

        [Parameter(Mandatory = $True, ParameterSetName="Body")]
        [string]$Body,

        [Parameter(Mandatory = $True, ParameterSetName="OutFile")]
        [ValidateNotNullOrEmpty()]
        [string]$OutFile,

        [Parameter(Mandatory = $False, ParameterSetName="Standard")]
        [Parameter(Mandatory = $False, ParameterSetName="Body")]
        [Parameter(Mandatory = $False, ParameterSetName="OutFile")]
        [switch]$AsWebRequest
    )

    $Parameters = Get-ParameterValues

    $RequestUri = [Uri]::new($Parameters.vRASession.ServerUri, $Parameters.ApiUriSegment)

    if (!$Parameters.ContainsKey("Headers")) {
        $Parameters.Headers = @{
            Accept = "application/json"
            Authorization = "Bearer $($Parameters.vRASession.Token)"
        }
    }

    $Params = @{
        Method = $Parameters.Method
        Headers = $Parameters.Headers
        ContentType = "application/json"
        Uri = $RequestUri
    }

    if ($Parameters.ContainsKey("Body")) {
        $Params.Body = $Parameters.Body
        Write-Debug -Message "The request body is: '$Parameters.Body'"
    } elseif ($Parameters.ContainsKey("OutFile")) {
        $Params.OutFile = $Parameters.OutFile
    }

    if (!($Parameters.vRASession.SignedCertificates) -and ($IsCoreCLR)) {
        $Params.SkipCertificateCheck = $true
    }

    if (($Parameters.vRASession.SslProtocol -ne 'Default') -and ($IsCoreCLR)) {
        $Params.SslProtocol = $Parameters.vRASession.SslProtocol
    }

    try {
        if ($Parameters.ContainsKey("WebRequest")) {
            Invoke-WebRequest @Params
        } else {
            Invoke-RestMethod @Params
        }
    } catch {
        throw
    } finally {
        if (!$IsCoreCLR) {

            <#
                Workaround for bug in Invoke-RestMethod. Thanks to the PowerNSX guys for pointing this one out
                https://bitbucket.org/nbradford/powernsx/src
            #>
            $ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($RequestUri)
            $ServicePoint.CloseConnectionGroup("") | Out-Null
        }
    }
}
