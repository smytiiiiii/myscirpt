# Telecharge la derniere version recommandee de FXServer (Windows) dans .\artifacts
# Utilisation : clic droit > "Executer avec PowerShell"
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$info = Invoke-RestMethod 'https://changelogs-live.fivem.net/api/changelog/versions/win32/server'
$url = $info.recommended_download
Write-Host "Telechargement de $url"

if (Test-Path artifacts) { Remove-Item artifacts -Recurse -Force }
New-Item -ItemType Directory artifacts | Out-Null
Invoke-WebRequest $url -OutFile artifacts\server.7z

# Extraction : 7-Zip si installe, sinon le tar integre a Windows
$sevenZip = @("$env:ProgramFiles\7-Zip\7z.exe", "${env:ProgramFiles(x86)}\7-Zip\7z.exe") |
    Where-Object { Test-Path $_ } | Select-Object -First 1
if ($sevenZip) {
    & $sevenZip x artifacts\server.7z -oartifacts -y | Out-Null
} else {
    tar -xf artifacts\server.7z -C artifacts
}

if (-not (Test-Path artifacts\FXServer.exe)) {
    Write-Host "Extraction impossible. Installe 7-Zip (https://www.7-zip.org) puis relance ce script."
    exit 1
}
Remove-Item artifacts\server.7z

if (-not (Test-Path secrets.cfg)) {
    Copy-Item secrets.cfg.example secrets.cfg
    Write-Host "secrets.cfg cree : mets-y ta cle de licence (https://portal.cfx.re)."
}

Write-Host "Installation terminee. Lance le serveur avec start.bat"
