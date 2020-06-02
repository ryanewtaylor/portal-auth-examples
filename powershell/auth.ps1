<#
.SYNOPSIS
    Authenticates a user using their CAC with Portal and generates a token
.EXAMPLE
    PS C:\> auth.ps1 -SubjectName ryan -PortalUrl HTTPS://YOUR.PORTAL.COM/PORTAL -ClientID YOUR_CLIENT_ID
.INPUTS
    string string string
.OUTPUTS
    None
.NOTES
    References:

    - https://powershell.org/forums/topic/download-file-with-smartcard-authentication/
    - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-6
    - https://stackoverflow.com/questions/41618766/powershell-invoke-webrequest-fails-with-ssl-tls-secure-channel
#>
using namespace System.Security.Cryptography.X509Certificates;
param(
    # Filter the list of certificates by their subject name
    [Parameter(Mandatory=$true)]
    [string]$CertSubjectName = "",

    [Parameter(Mandatory=$true)]
    [string]$PortalUrl = "",

    [Parameter(Mandatory=$true)]
    [string]$ClientID = ""
)
Add-Type -AssemblyName System.Security

[Net.ServicePointManager]::SecurityProtocol = "tls12"

# prompt to select a certificate
$certs = [X509Certificate2[]](
    Get-ChildItem Cert:\CurrentUser\My `
    | Where-Object { ($_.NotAfter -gt (Get-Date)) -and ($_.SubjectName.Name -like "*$CertSubjectName*") })

if ($null -eq $certs) {
    Write-Host "No certificats found with that Subject Name"
    exit 1
}

$cert = [X509Certificate2UI]::SelectFromCollection(
    $certs,
    "Select a certificate",
    "Select a certificate",
    "SingleSelection") `
| Select-Object -First 1

# login and capture details in a seession
$webResp = Invoke-WebRequest `
    -Uri "$PortalUrl/sharing/rest/oauth2/authorize?client_id=$ClientID&redirect_uri=https://localhost:8080&response_type=token&locale=en#" `
    -Certificate $cert `
    -SessionVariable "session"

# fetch a token
$json = @{username = ""; password = ""; ip = ""; client="referer"; referer = ""; expiration = 60; f = "pjson" }
$tokenResp = Invoke-RestMethod `
    -Method Post `
    -ContentType "application/x-www-form-urlencoded" `
    -Uri "$PortalUrl/sharing/rest/generateToken" `
    -Body $json `
    -Certificate $Cert `
    -WebSession $session

Write-Host "Token: $($tokenResp.token)"
Write-Host "Expires: $($tokenResp.expires)"
Write-Host "Use SSL $($tokenResp.ssl)"
Write-Host
