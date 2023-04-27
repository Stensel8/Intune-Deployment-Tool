Write-Host ''
Write-Host ''
Write-Host 'Installatiebestanden binnenhalen van Adobe server(s)...'

$webclient = New-Object System.Net.WebClient
$url = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2300120064/AcroRdrDC2300120064_nl_NL.exe"
$outputfile = "AcroRdrDC2300120064_nl_NL.exe"
$webClient.DownloadFile($url, $outputFile)



Write-Host '.EXE uitpakken...'
Start-Process -FilePath .\AcroRdrDC2300120064_nl_NL.exe -ArgumentList '-sfx_o"C:\AdobeReaderExtracted" -sfx_ne.\AcroRdrDC2300120064_nl_NL.exe -sfx_o"C:\AdobeReaderExtracted" -sfx_ne' -Wait

Write-Host 'Aangepaste installer maken...'
Start-Process -FilePath msiexec -ArgumentList '/a c:\AdobeReaderExtracted\AcroRead.msi TARGETDIR="c:\AcrobatReaderDC_AIP" /quiet' -Wait

write-host ''
Write-Host '75%'
Write-Host ''
Write-Host 'Bestanden samenvoegen, dit kan even duren...'
Start-Process -FilePath msiexec -ArgumentList '/a C:\AcrobatReaderDC_AIP\AcroRead.msi /p C:\AdobeReaderExtracted\AcroRdrDCUpd2300120064.msp /quiet' -Wait

Write-Host '80%'
New-Item C:\AcrobatReaderDC_AIP\setup.ini
Set-Content C:\AcrobatReaderDC_AIP\setup.ini @"
[Startup]
RequireMSI=3.0
CmdLine=/sall /rs

[Product]
msi=AcroRead.msi
"@

Write-Host ''
Write-Host '90%'
Write-Host ''
Write-Host ''
Write-Host 'Oude installatiebestanden opschonen, een moment geduld...'
Rename-Item C:\AcrobatReaderDC_AIP C:\AcrobatReaderDC_2023.001.200064
Set-Location "C:\Users\$env:USERNAME\Downloads"
Move-Item C:\AcrobatReaderDC_2023.001.200064 .\AcrobatReaderDC_2023.001.200064
Remove-Item C:\AdobeReaderExtracted -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item .\AcroRdrDC2300120064_nl_NL.exe -Force -Recurse -ErrorAction SilentlyContinue
Write-Host ''
Write-Host ''
Write-Host '.MSI bestand is gereed!'
Write-Host ''
Write-Host 'Script zal nu afsluiten!'
Start-Sleep -seconds 7
