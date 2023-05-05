  # Checking if the script is being run with admin rights. If not, the script will automatically be run again as admin.
  if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
  }
  
  
  Write-Host "We need 7-Zip to compress and decompress files since Windows Explorer doesn't know how to unpack an .exe.
  
  Checking if 7-Zip is installed, and if not, 7-Zip will automatically be installed."
  Write-Host ""
  Write-Host ""
  Write-Host ""
  Start-Sleep -Seconds 5
  # Import Chocolately and use it as package manager.
  if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  }
  
  # Check if 7-Zip is installed, and if not, install 7-Zip via Chocolatey.
  # We need 7-Zip to compress and decompress files since Windows Explorer doesn't know how to unpack an .exe.
  choco install 7zip -y
  
  
  # Download the Adobe Acrobat Reader DC .exe installer to the Downloads folder.
  Write-Host ""
  Write-Host ""
  Write-Host ""
  Write-Host ""
  
  Write-Host "->  Downloading installation files from Adobe server(s)..."
  Write-Host ""
  
  New-Item -ItemType Directory "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\" -Force | Out-Null
  Set-Location "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\"
  
  $sourceUrl = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300120064/AcroRdrDCx642300120064_nl_NL.exe"
  $fallbackUrl = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300120064/AcroRdrDCx642300120064_nl_NL.exe"
  $outputPath = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\AcroRdrDC2300120064_nl_NL.exe"
  
  # Download the file using the primary URL
  Write-Output "Downloading Adobe Acrobat Reader DC from primary URL..."
  try {
      Start-BitsTransfer -Source $sourceUrl -Destination $outputPath -ErrorAction Stop
  } catch {
      Write-Output "Failed to download from primary URL: $($_.Exception.Message)"
      Write-Output "Downloading Adobe Acrobat Reader DC from fallback URL..."
      try {
          Start-BitsTransfer -Source $fallbackUrl -Destination $outputPath -ErrorAction Stop
      } catch {
          Write-Output "Failed to download from fallback URL: $($_.Exception.Message)"
          Write-Output "Failed to download Adobe Acrobat Reader DC from both primary and fallback URLs. Exiting script."
          exit 1
      }
  }
  
  Write-Output "Adobe Acrobat Reader DC downloaded successfully at $outputPath"
  
  
  Write-Host "Extracting .EXE file to individual files..."
  Start-Process -FilePath "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\AcroRdrDC2300120064_nl_NL.exe" -ArgumentList "-sfx_o`"$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup`" -sfx_ne -quiet" -Wait
  Write-Host ".EXE file extracted to the downloadfolder."
  



  #Write-Host ''
  #Write-Host ''
  #Write-Host '->  Downloading Customization Wizard from Adobe server(s)...'

  $sourceUrl2   = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
  $fallbackUrl2 = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
  $outputPath2  = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\CustWiz2200320310_en_US_DC.exe"
 
  Write-Output "Downloading Adobe Acrobat Reader DC Customization Wizard from primary URL..."

  try {
    Start-BitsTransfer -Source $sourceUrl2 -Destination $outputPath2 -ErrorAction Stop
} catch {
    Write-Output "Failed to download from primary URL: $($_.Exception.Message)"
    Write-Output "Downloading Acrobat Customization Wizard from fallback URL..."
    try {
        Start-BitsTransfer -Source $fallbackUrl2 -Destination $outputPath2 -ErrorAction Stop
    } catch {
        Write-Output "Failed to download from fallback URL: $($_.Exception.Message)"
        Write-Output "Failed to download Acrobat Customization Wizard from both primary and fallback URLs. Exiting script."
        exit 1
    }
}


  
  $source = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\CustWiz2200320310_en_US_DC.exe"
  $destination = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\"
  
  # Extract the .msi file from the .exe file using 7-Zip.
  & "C:\Program Files\7-Zip\7z.exe" e "$source" "*.msi" -o"$destination"
  
  
  # Delete the original .exe file.
  Remove-Item "$source"
  
  # Install the Adobe Customization software silently and suppress reboots.
  Write-Host ""
  Write-Host ""
  Write-Host ""
  Write-Host "Installing the Adobe Customization software..."
  Start-Sleep -Seconds 2
  $Custwiz_msi = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\CustWiz.msi"
  Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$Custwiz_msi`" /qn /norestart" -Wait
  
  
  
  Start-Sleep -Seconds 3
  Write-Host ''
  Write-Host ''
  Write-Host ''
  Write-Host ''
  Write-Host '->  Downloading Microsoft Intune Win32 Content Prep Tool from GitHub server(s)...'
  Write-Host ''
  $webclient3 = New-Object System.Net.WebClient
  $url3 = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip"
  $outputfile3 = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Microsoft Win32 Content Prep Tool.zip"
  $webclient3.DownloadFile($url3, $outputfile3)
  
  Write-Host "Extracting Microsoft Win32 Content Prep Tool..."
  Expand-Archive -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Microsoft Win32 Content Prep Tool.zip" -DestinationPath "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Intune"
  Remove-Item -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Microsoft Win32 Content Prep Tool.zip"
  Write-Host ".ZIP extracted."
  
  Start-Sleep -Seconds 5
  Write-Host ''
  Write-Host ''
  Write-Host ""
  Write-Host ""
  Write-Host ""
  
  Write-Host "All necessary installation files to package Adobe Acrobat in Microsoft Intune have been downloaded to:
  
  $env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup."
  Start-Sleep -Seconds 2
  Write-Host ''
  Write-Host ""
  Write-Host ""
  Write-Host "Opening the Adobe Customization Wizard.."
  for ($i = 5; $i -ge 0; $i--) {
  Write-Host $i
  Start-Sleep -Seconds 1
  }
  
  Start-Process -FilePath "C:\Program Files (x86)\Adobe\Acrobat Customization Wizard DC\CustWiz.exe"
  Invoke-Item -Path $destination
  
  # Exit the script
  Write-Host ""
  Write-Host ""
  Write-Host "This script will exit in 5 seconds..."
  
  for ($i = 5; $i -ge 0; $i--) {
    Write-Host $i
    Start-Sleep -Seconds 1
  }
  exit
  
