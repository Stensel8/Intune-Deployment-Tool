# Checking if the script is being run with admin rights. If not, the script will automatically be run again as admin.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Start-Process powershell.exe -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
  Exit
}

# Variables
$Installation_directory = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup"

# Prompt the user for customization preference.
$customizationChoice = Read-Host "Do you want the ability to customize the Adobe Acrobat installer? (y/n)

Note: This process will use 7-zip in the background to compress and decompress files. If you don't have 7-zip installed, it will be installed automatically."

if ($customizationChoice -eq "y") {
  Write-Output ""
  Write-Output "We need 7-Zip to compress and decompress files since Windows Explorer doesn't know how to unpack
and silently install the Adobe customization software."
  Write-Output ""
  Write-Output ""
  Write-Output ""
  Start-Sleep -Seconds 5

  # Import Chocolatey and use it as a package manager.
  if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $url = 'https://chocolatey.org/install.ps1'
    $path = Join-Path $env:TEMP 'install.ps1'
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($url, $path)
    Unblock-File -Path $path

    # Dot-source the install script to load its functions and variables
    . $path
}


  # Check if 7-Zip is installed, and if not, install 7-Zip via Chocolatey.
  # We need 7-Zip to compress and decompress files since Windows Explorer doesn't know how to unpack and silently install the Adobe customization software.
  choco install 7zip -y

  # Download the Adobe Customization software silently because we need it to customize the Adobe Reader DC installation.
  Write-Output ""
  Write-Output ""
  Write-Output "-> Downloading Customization Wizard from Adobe server(s)..."
  $url2 = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
  $url3 = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
  $outputfile = Join-Path $Installation_directory "Customization Wizard 2200320310.exe"

  $webClient = New-Object System.Net.WebClient

  try {
      $webClient.DownloadFile($url2, $outputfile)
  } catch {
      Write-Output "Download from the primary server failed. Attempting to download from the fallback server..."

      try {
          $webClient.DownloadFile($url3, $outputfile)
      } catch {
          Write-Output "Download from the fallback server also failed. Unable to download the file."
      }
  }

  $webClient.Dispose()


  $source = Join-Path $Installation_directory "Customization Wizard 2200320310.exe"

  # Extract the Customization software file from the .exe using 7-Zip.
  & "C:\Program Files\7-Zip\7z.exe" e "$source" "*.msi" -o"$Installation_directory"

  # Delete the original .exe file.
  Remove-Item $source

# Install the Adobe Customization software silently and suppress reboots.
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output "Installing the Adobe Customization software..."
Start-Sleep -Seconds 2
$msiFile = Join-Path $Installation_directory "CustWiz.msi"
$arguments = "/i `"$msiFile`" /qn /norestart"
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -PassThru -Wait

if ($process.ExitCode -eq 0) {
    Write-Output "Installation completed successfully."
} else {
    Write-Output "Installation failed with exit code: $($process.ExitCode)."
}}

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
Expand-Archive -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Microsoft Win32 Content Prep Tool.zip" -DestinationPath "$env:USERPROFILE\Downloads" -Force
Remove-Item -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Microsoft Win32 Content Prep Tool.zip" -Force -ErrorAction SilentlyContinue
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



$confirmation = Read-Host "Intune packaging will begin soon.

Do you want to customize the Acrobat installer before packaging it to an .INTUNEWIN? (Type 'y' or 'n')"

if ($confirmation.ToLower() -eq "y") {
    Write-Output "Opening the Adobe Customization Wizard.."
    Start-Sleep -Seconds 1
    Start-Process -FilePath "C:\Program Files (x86)\Adobe\Acrobat Customization Wizard DC\CustWiz.exe"
    Invoke-Item -Path $Installation_directory
}
else {
    Write-Output ""
    Write-Output "Customization is cancelled by user, script will now use the predefined SETUP and MST files..."
    Start-Sleep -Seconds 2
    $setup_ini = "https://github.com/Stensel8/Intune-Deployment-Tool/raw/main/Resources/setup.ini"
    $AcroPro_mst = "https://github.com/Stensel8/Intune-Deployment-Tool/raw/main/Resources/AcroPro.mst"
    (New-Object System.Net.WebClient).DownloadFile($setup_ini, "$Installation_directory\setup.ini")
    (New-Object System.Net.WebClient).DownloadFile($AcroPro_mst, "$Installation_directory\AcroPro.mst")
}


# Cleaning up some files otherwise the script will attempt to package these and that will fail.
Start-Sleep -Seconds 2
Remove-Item -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\AcroRdrDCx642300120174_nl_NL.exe" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\CustWiz.msi" -Force -ErrorAction SilentlyContinue

$Adobe_source_file = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Acropro.msi"
$Adobe_output_folder = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\INTUNEWIN"
Start-Process "$env:USERPROFILE\Downloads\Microsoft-Win32-Content-Prep-Tool-master\IntuneWinAppUtil" -ArgumentList "-c $Installation_directory -s $Adobe_source_file -o $Adobe_output_folder -q" -Wait
1..2 | ForEach-Object{"`n"}
Write-Output "Adobe Acrobat Reader packaged succesfully, the package can be found in the INTUNEWIN folder."




# Exit the script
Write-Output ""
Write-Output ""
Write-Output "Script completed, the script will now close..."
Start-Sleep -Seconds 5
Exit
