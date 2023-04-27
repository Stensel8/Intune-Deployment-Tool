Write-Host ''
Write-Host ''
Write-Host 'Installatiebestanden binnenhalen van Adobe server(s)...'

$webclient = New-Object System.Net.WebClient
$url = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300120143/AcroRdrDCx642300120143_nl_NL.exe"
$outputfile = "AcroRdrDCx642300120143_nl_NL.exe"
$webclient.DownloadFile($url, $outputfile)



Write-Host '.EXE uitpakken...'
Start-Process -FilePath .\AcroRdrDCx642300120143_nl_NL.exe -ArgumentList '-sfx_o"C:\AdobeReaderx64Extracted" -sfx_ne.\AcroRdrDCx642300120143_nl_NL.exe -sfx_o"C:\AdobeReaderx64Extracted" -sfx_ne' -Wait

Write-Host 'Aangepaste installer maken...'
Start-Process -FilePath msiexec -ArgumentList '/a c:\AdobeReaderx64Extracted\AcroPro.msi TARGETDIR="c:\AcrobatReaderDCx64_AIP" /quiet' -Wait

write-host ''
Write-Host '75%'
Write-Host ''
Write-Host 'Bestanden samenvoegen, dit kan even duren...'
Start-Process -FilePath msiexec -ArgumentList '/a C:\AcrobatReaderDCx64_AIP\AcroPro.msi /p C:\AdobeReaderx64Extracted\AcroRdrDCx64Upd2300120143.msp /quiet' -Wait

Write-Host '80%'
New-Item C:\AcrobatReaderDCx64_AIP\setup.ini
Set-Content C:\AcrobatReaderDCx64_AIP\setup.ini @"
[Startup]
RequireMSI=3.0
CmdLine=/sall /rs

[Product]
msi=AcroPro.msi
"@

Write-Host ''
Write-Host '90%'
Write-Host ''
Write-Host ''
Write-Host 'Oude installatiebestanden opschonen, een moment geduld...'
Rename-Item C:\AcrobatReaderDCx64_AIP C:\AcrobatReaderDCx642300120143_nl_NL.exe
Set-Location "C:\Users\$env:USERNAME\Downloads"
Move-Item C:\AcrobatReaderDCx642300120143_nl_NL.exe .\AcrobatReaderDCx64_2023.001.20143
Remove-Item C:\AdobeReaderx64Extracted -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item .\AcroRdrDCx642300120143_nl_NL.exe -Force -Recurse -ErrorAction SilentlyContinue
Write-Host ''
Write-Host '.MSI bestand is gereed!'
Write-Host ''
Write-Host 'Script zal nu afsluiten'
Start-Sleep -seconds 7
