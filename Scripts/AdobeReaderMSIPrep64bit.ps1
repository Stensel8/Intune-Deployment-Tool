# Controleren of het script met admin-rechten wordt uitgevoerd. Als dit niet het geval is, zal het script automatisch opnieuw worden uitgevoerd als admin.
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
  }


Write-Host ''
Write-Host '->  Installatiebestanden binnenhalen van Adobe server(s)...'
Write-Host ''

New-Item -ItemType Directory "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\" -Force | Out-Null
Set-Location "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\"

$webclient = New-Object System.Net.WebClient
$url = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300120143/AcroRdrDCx642300120143_nl_NL.exe"
$outputfile = "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\AcroRdrDCx642300120143_nl_NL.exe"
$webclient.DownloadFile($url, $outputfile)

Write-Host ".EXE bestand uitpakken naar losse bestanden..."
Start-Process -FilePath "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\AcroRdrDCx642300120143_nl_NL.exe" -ArgumentList "-sfx_o`"$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup`" -sfx_ne -quiet" -Wait
Write-Host ".EXE bestand uitgepakt."


Write-Host ''
Write-Host ''
Write-Host '->  Customization Wizard binnenhalen van Adobe server(s)...'
$webclient2 = New-Object System.Net.WebClient
$url2 = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
$outputfile2 = "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\Customization Wizard 2200320310.exe"
$webclient2.DownloadFile($url2, $outputfile2)

Start-Sleep -Seconds 3

Write-Host '->  Microsoft Intune Win32 Content Prep Tool binnenhalen van GitHub server(s)...'
Write-Host ''
$webclient3 = New-Object System.Net.WebClient
$url3 = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip"
$outputfile3 = "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\Microsoft Win32 Content Prep Tool.zip"
$webclient3.DownloadFile($url3, $outputfile3)

Write-Host "Uitpakken van Microsoft Win32 Content Prep Tool..."
Expand-Archive -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\Microsoft Win32 Content Prep Tool.zip" -DestinationPath "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\Intune"
Remove-Item -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\Microsoft Win32 Content Prep Tool.zip"
Write-Host ".ZIP uitgepakt."

Start-Sleep -Seconds 5
Write-Host ''
Write-Host ''
Write-Host "Alle benodigde installatiebestanden om Adobe Acrobat te packagen in Microsoft Intune zijn gedownload naar $env:USERPROFILE\Downloads\Adobe-Acrobat-Setup."
Start-Sleep -Seconds 2
Write-Host "Script zal nu afsluiten."
Start-Sleep -Seconds 5
