Write-Host ''
Write-Host ''
Write-Host 'Installatiebestanden binnenhalen van Adobe server(s)...'

New-Item -ItemType Directory "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\" -Force
Set-Location "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\"

$webclient = New-Object System.Net.WebClient
$url = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300120143/AcroRdrDCx642300120143_nl_NL.exe"
$workingdir = "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup"
$outputfile = "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\AcroRdrDCx642300120143_nl_NL.exe"
$webclient.DownloadFile($url, $outputfile)


Write-Host ".EXE bestand uitpakken naar losse bestanden..."

Start-Process -FilePath "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\AcroRdrDCx642300120143_nl_NL.exe" -ArgumentList "-sfx_o`"$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup`" -sfx_ne -quiet" -Wait


Write-Host ''
Write-Host ''
Write-Host 'Customization Wizard binnenhalen van Adobe server(s)...'
$webclient2 = New-Object System.Net.WebClient
$url2 = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
$workingdir = "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup"
$outputfile2 = "$env:USERPROFILE\Downloads\Adobe-Acrobat-Setup\Customization Wizard 2200320310.exe"
$webclient2.DownloadFile($url2, $outputfile2)


Write-Host "Alle benodigde installatiebestanden voor Adobe Acrobat zijn gedownload naar $workingdir."
Start-Sleep -Seconds 5
Write-Host "Script zal nu afsluiten."
Start-Sleep -Seconds 3
