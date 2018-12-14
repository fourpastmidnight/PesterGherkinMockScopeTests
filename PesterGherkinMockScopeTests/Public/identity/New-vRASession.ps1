function New-vRASession {
    [CmdletBinding(DefaultParameterSetName="Credential")]
    [OutputType('vRASession')]
    # This function doesn't actually modify system state, so this rule can be safely ignored.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    param (
        [Parameter(Mandatory=$true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Server', '-Server', 's')]
        [string]$vRAServer,

        [Parameter(Mandatory=$false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Alias('Tenant', 't', '-tenant-url-token')]
        [string]$TenantUrlToken,

        [parameter(Mandatory=$true, ParameterSetName="Username")]
        [ValidateNotNullOrEmpty()]
        [Alias('User', 'u', '-user')]
        [string]$Username,

        [parameter(Mandatory=$true, ParameterSetName="Username")]
        [ValidateNotNullOrEmpty()]
        [Alias('-password', 'p')]
        [SecureString]$Password,

        [Parameter(Mandatory=$true, Position = 2, ParameterSetName="Credential")]
        [ValidateNotNullOrEmpty()]
        [Alias('-credential', 'c')]
        [Management.Automation.PSCredential]$Credential,

        [parameter(Mandatory=$false)]
        [ALias('-ignore-cert-requirements', 'i')]
        [switch]$IgnoreCertRequirements,

        [parameter(Mandatory=$false)]
        [ValidateSet('Ssl3', 'Tls', 'Tls11', 'Tls12')]
        [Alias('-ssl-protocol')]
        [string]$SslProtocol,

        [Alias('-with-api-version')]
        [switch]$RetrieveApiVersion
    )

    $SignedCertificates = $True

    if ($PSBoundParameters.ContainsKey("IgnoreCertRequirements") ){

        if (!$IsCoreCLR) {

            if ( -not ("TrustAllCertsPolicy" -as [type])) {

                Add-Type @"
                using System.Net;
                using System.Security.Cryptography.X509Certificates;
                public class TrustAllCertsPolicy : ICertificatePolicy {
                    public bool CheckValidationResult(
                        ServicePoint srvPoint, X509Certificate certificate,
                        WebRequest request, int certificateProblem) {
                        return true;
                    }
                }
"@
            }
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

        }

        $SignedCertificates = $false

    }

    $SslProtocolResult = 'Default'

    if ($PSBoundParameters.ContainsKey("SslProtocol") ){

        if (!$IsCoreCLR) {

            $CurrentProtocols = ([System.Net.ServicePointManager]::SecurityProtocol).toString() -split ', '
            if (!($SslProtocol -in $CurrentProtocols)){

                [System.Net.ServicePointManager]::SecurityProtocol += [System.Net.SecurityProtocolType]::$($SslProtocol)
            }
        }
        $SslProtocolResult = $SslProtocol
    }

    if ($PSBoundParameters.ContainsKey("Password")){
        $Credential = New-Object System.Management.Automation.PSCredential -Argument $Username, $Password
    }

    $networkCredential = $Credential.GetNetworkCredential()

    $vRAServerUri = [Uri]::new("https://${vRAServer}/")

    $Params = @{
        Uri = [Uri]::new($vRAServerUri, "identity/api/tokens")
        Method = "POST"
        Headers = @{
            Accept = "application/json"
        }
        ContentType = "application/json"
        Body = ConvertTo-Json @{
            username = $networkCredential.Username
            password = $networkCredential.Password
            tenant = $TenantUrlToken
        }
    }

    if ((!$SignedCertificates) -and ($IsCoreCLR)) {
        $Params.SkipCertificateCheck = $true
    }

    if (($SslProtocolResult -ne 'Default') -and ($IsCoreCLR)) {
        $Params.SslProtocol = $SslProtocol
    }

    $response = Invoke-RestMethod @Params | ConvertFrom-JSON

    $vRASession = [PSCustomObject]@{
        PSTypeName = 'vRASession'
        ServerUri = $vRAServerUri
        Token = $response.id
        SessionExpiration = [DateTimeOffset]::Parse($response.expires)
        TenantId = $response.tenant
        Username = $Credential.Username
        APIVersionData = $Null
        SignedCertificates = $SignedCertificates
        SslProtocol = $SslProtocolResult
    }

    if ($RetrieveApiVersion) {
        $vRASession.TenantId = (Get-vRATenant $vRASession -Id $Tenant).id
    }

    $vRASession
}
