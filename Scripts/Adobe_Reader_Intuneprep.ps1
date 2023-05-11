﻿# Checking if the script is being run with admin rights. If not, the script will automatically be run again as admin.
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
  Exit
}


Write-Output "We need 7-Zip to compress and decompress files since Windows Explorer doesn't know how to unpack an .exe.

Checking if 7-Zip is installed, and if not, 7-Zip will automatically be installed."
Write-Output ""
Write-Output ""
Write-Output ""
Start-Sleep -Seconds 5
# Import Chocolately and use it as package manager.
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
  $url = 'https://chocolatey.org/install.ps1'
  $path = Join-Path $env:TEMP 'install.ps1'
  Start-BitsTransfer -Source $url -Destination $path
  Unblock-File $path
  & $path
}

# Check if 7-Zip is installed, and if not, install 7-Zip via Chocolatey.
# We need 7-Zip to compress and decompress files since Windows Explorer doesn't know how to unpack an .exe.
choco install 7zip -y


# Download the Adobe Acrobat Reader DC .exe installer to the Downloads folder.
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output ""

Write-Output "->  Downloading installation files from Adobe server(s)..."
Write-Output ""

New-Item -ItemType Directory "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\" -Force | Out-Null
Set-Location "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\"

$sourceUrl = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300120174/AcroRdrDCx642300120174_nl_NL.exe"
$fallbackUrl = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300120174/AcroRdrDCx642300120174_nl_NL.exe"
$fileName = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\AcroRdrDCx642300120174_nl_NL.exe"

 # Download the file using the primary URL
Write-Output "Downloading Adobe Acrobat Reader DC..."
try {
  Start-BitsTransfer -Source $sourceUrl -Destination $fileName
} catch {
  # Download the file using the fallback URL
  Write-Output "Failed to download from primary server: $($_.Exception.Message)"
  Write-Output "Downloading Adobe Acrobat Reader DC from fallback server..."
  try {
      Start-BitsTransfer -Source $fallbackUrl -Destination $fileName -ErrorAction Stop
  } catch {
      Write-Output "Failed to download from fallback server, are the downloadservers up-and-running?: $($_.Exception.Message)"
      exit 1
  }
}

Write-Output "Extracting .EXE file to individual files..."
Start-Process -FilePath "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\AcroRdrDCx642300120174_nl_NL.exe" -ArgumentList "-sfx_o`"$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup`" -sfx_ne -quiet" -Wait
Write-Output ".EXE file extracted to the downloadfolder."

Write-Output ""
Write-Output ""
Write-Output "->  Downloading Customization Wizard from Adobe server(s)..."
$webclient2 = New-Object System.Net.WebClient
$url2 = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
$outputfile2 = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Customization Wizard 2200320310.exe"
$webclient2.DownloadFile($url2, $outputfile2)

$source = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Customization Wizard 2200320310.exe"
$destination = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup"

# Extract the .msi file from the .exe file using 7-Zip.
& "C:\Program Files\7-Zip\7z.exe" e "$source" "*.msi" -o"$destination"

# Delete the original .exe file.
Remove-Item "$source"

# Install the Adobe Customization software silently and suppress reboots.
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output "Installing the Adobe Customization software..."
Start-Sleep -Seconds 2
$msiFile = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\CustWiz.msi"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiFile`" /qn /norestart" -Wait



Start-Sleep -Seconds 3
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output "->  Downloading Microsoft Intune Win32 Content Prep Tool from GitHub server(s)..."
Write-Output ""
$webclient3 = New-Object System.Net.WebClient
$url3 = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip"
$outputfile3 = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Microsoft Win32 Content Prep Tool.zip"
$webclient3.DownloadFile($url3, $outputfile3)

Write-Output "Extracting Microsoft Win32 Content Prep Tool..."
Expand-Archive -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Microsoft Win32 Content Prep Tool.zip" -DestinationPath "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Intune"
Remove-Item -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Microsoft Win32 Content Prep Tool.zip"
Write-Output ".ZIP extracted."

Start-Sleep -Seconds 5
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output ""

Write-Output "All necessary installation files to package Adobe Acrobat in Microsoft Intune have been downloaded to:

$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup."
Start-Sleep -Seconds 2
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output "Opening the Adobe Customization Wizard.."
for ($i = 5; $i -ge 0; $i--) {
Write-Output $i
Start-Sleep -Seconds 1
}

Start-Process -FilePath "C:\Program Files (x86)\Adobe\Acrobat Customization Wizard DC\CustWiz.exe"
Invoke-Item -Path $destination

# Cleaning up files...
Start-Sleep -Seconds 2
Remove-Item -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\AcroRdrDCx642300120174_nl_NL.exe" -Force -ErrorAction Ignore
Remove-Item -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\CustWiz.msi" -Force -ErrorAction Ignore


# Exit the script
Write-Output ""
Write-Output ""
Write-Output "This script will exit in 5 seconds..."

for ($i = 5; $i -ge 0; $i--) {
  Write-Output $i
  Start-Sleep -Seconds 1
}
exit
