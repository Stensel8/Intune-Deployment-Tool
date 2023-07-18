do
{

# Checking if the script is being run with admin rights. If not, the script will automatically be run again as admin.
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
  }
  Clear-Host
  1..1 | ForEach-Object{"`n"}
  Write-Output "Menu:"
  1..2 | ForEach-Object{"`n"}

Write-Output "1. Choice 1: Google Chrome (64-bit)"
Write-Output "2. Choice 2: Adobe Acrobat Reader DC (64-bit)"
#Write-Output "3. Choice 3:
Write-Output "4. Choice 4: Citrix Workspace (64-bit)"
1..1 | ForEach-Object{"`n"}
$choice = Read-Host "Enter the number of your choice"


switch ($choice) {

    "1" {
        # Execute the code for Choice 1
        Write-Output "You have choosen option 1..."
        Write-Output "Google Chrome Standalone Enterprise Installer will be downloaded and packaged..."
        Start-Sleep -seconds 2

    $intunePath = "$env:SystemDrive\Intune"
    if  (Test-Path $intunePath) {
     Write-Output "Folder already exists..."
    }
    else {
       New-Item -ItemType directory -Path $intunePath

    }


    $ZipFile = "$intunePath\temp.zip"
    New-Item $ZipFile -ItemType File -Force

    $RepositoryZipUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip"
    # Download the .zip file
    Write-Output 'Starting downloading the GitHub Repository'
    Start-BitsTransfer -Source $RepositoryZipUrl -Destination $ZipFile
    Write-Output 'Download finished, now beginning to package the application...'
    Start-Sleep -seconds 2




    # Extract the .zip file
    Write-Output 'Starting unzipping the GitHub Repository locally'
    Expand-Archive -Path $ZipFile -DestinationPath $intunePath -Force
    Write-Output 'Unzip finished'
    Remove-Item -Path $ZipFile -Force

    Copy-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\* -Destination $intunePath -PassThru
    Remove-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\ -Force -Recurse

    $ChromeSourcePath = "$env:SystemDrive\Intune\GoogleChrome\Source"
    $ChromeOutputPath = "$env:SystemDrive\Intune\GoogleChrome\Output"
    if ( (Test-Path $ChromeSourcePath) -or (Test-Path $ChromeOutputPath))  {
        Write-Output "Folder already exists."
    }
    else {
        New-Item -ItemType directory -Path $ChromeSourcePath
        New-Item -ItemType directory -Path $ChromeOutputPath
    }


    $Link = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
    $fileName = "$env:SystemDrive\Intune\GoogleChrome\Source\GoogleChromeStandaloneEnterprise64.msi"

    Write-Output 'Starting downloading the Google Chrome MSI'
    Start-BitsTransfer -Source $Link -Destination $fileName
    Write-Output 'Download finished, now beginning to package the application...'
    Start-Sleep -seconds 2



    Start-Process C:\Intune\IntuneWinAppUtil.exe -ArgumentList "-c `"$ChromeSourcePath`" -s GoogleChromeStandaloneEnterprise64.msi -o `"$ChromeOutputPath`""  -Wait
    1..2 | ForEach-Object{"`n"}
    Write-Output "Google Chrome has been packaged successfully!"
     }

    "2" {
      # Execute code for Choice 2
    Write-Output "You have chosen option 2...

    Adobe Acrobat Reader DC  (64-bit) will be downloaded and packaged..."



# Variables
$Installation_directory = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup"

# Prompt the user for customization preference.
$customizationChoice = Read-Host "
Do you want the ability to customize the Adobe Acrobat installer? (y/n)

Note: This process will use 7-zip in the background to compress and decompress files.
If you don't have 7-zip installed, it will be installed automatically. (y/n default is n)"

if ($customizationChoice -eq "y") {
  Write-Output ""
  Write-Output "Silently installing 7-Zip. (if not already installed)"
  Write-Output ""
  Write-Output ""
  Write-Output ""
  Start-Sleep -Seconds 5

  # We need 7-Zip to compress and decompress files since Windows Explorer doesn't know how to unpack and silently install the Adobe customization software.
  # Download the 7-Zip silently.
  $exitCode = (Start-Process -FilePath msiexec.exe -ArgumentList "/i https://www.7-zip.org/a/7z2201-x64.msi /qn /norestart" -Wait -PassThru).ExitCode
  if ($exitCode -eq 0) { "Installation succeeded!" } else { "Installation failed! Exit code: $exitCode" }


 # Download the Adobe Customization software from Adobe server(s).
  Write-Output ""
  Write-Output ""
  Write-Output "-> Downloading Customization Wizard from Adobe server(s)..."
  $url2 = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
  $url3 = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
  $outputfile = Join-Path $Installation_directory "Customization Wizard 2200320310.exe"

  try {
      Import-Module BitsTransfer -ErrorAction Stop
      Start-BitsTransfer -Source $url2 -Destination $outputfile -ErrorAction Stop
  } catch {
      Write-Output "Download from the primary server failed. Attempting to download from the fallback server..."

      try {
          Start-BitsTransfer -Source $url3 -Destination $outputfile -ErrorAction Stop
      } catch {
          Write-Output "Download from the fallback server also failed. Unable to download the file."
      }
  }



  $source = Join-Path $Installation_directory "Customization Wizard 2200320310.exe"

  # Extract the Customization software file from the .exe using 7-Zip.
  & "C:\Program Files\7-Zip\7z.exe" e "$source" "*.msi" -o"$Installation_directory" -aoa



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
    Write-Output "Installation failed with exit code: $($process.ExitCode).

NOTE: You may need to try again or use the Adobe Customization software manually."
    Start-Sleep -Seconds 2
    Write-Output "Script will now continue..."
    Start-Sleep -Seconds 2
}}

# Download the Adobe Acrobat Reader DC .exe installer to the Downloads folder.
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output ""

Write-Output "->  Downloading Acrobat installation files from Adobe server(s)..."
Write-Output ""

New-Item -ItemType Directory "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\" -Force | Out-Null
Set-Location "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\"

$sourceUrl = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300320244/AcroRdrDCx642300320244_nl_NL.exe"
$fallbackUrl = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300320244/AcroRdrDCx642300320244_nl_NL.exe"
$fileName = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\AcroRdrDCx642300320244_nl_NL.exe"

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
Start-Process -FilePath "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\AcroRdrDCx642300320244_nl_NL.exe" -ArgumentList "-sfx_o`"$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup`" -sfx_ne -quiet" -Wait
Write-Output ".EXE file extracted to the downloadfolder."



Start-Sleep -Seconds 3
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output "-> Downloading Microsoft Intune Win32 Content Prep Tool from GitHub server(s)..."
Write-Output ""
$Intune_Prep_URL = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe"
$Intune_Prep_Path = "$env:USERPROFILE\Downloads\IntunePrepTool\IntuneWinAppUtil.exe"

$destinationFolder = Split-Path $Intune_Prep_Path -Parent
if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -Path $destinationFolder -ItemType Directory -Force
}

Start-BitsTransfer -Source $Intune_Prep_URL -Destination $Intune_Prep_Path



Start-Sleep -Seconds 5
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output ""

# Cleaning up old installtion files.
Write-Output "Cleaning up 2 files, otherwise the script will attempt to package these too and that will fail."
Start-Sleep -Seconds 2
Remove-Item -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\AcroRdrDCx642300320244_nl_NL.exe" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\CustWiz.msi" -Force -ErrorAction SilentlyContinue
start-sleep -Seconds 1
Write-Output "

"

$Adobe_source_file = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\Acropro.msi"
$Adobe_output_folder = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup\INTUNEWIN"
Write-Output "All necessary installation files to package Adobe Acrobat in Microsoft Intune have been downloaded to:

$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup."
Start-Sleep -Seconds 2
Write-Output ""
Write-Output ""
Write-Output ""


if ($customizationChoice -eq "y") {
    $confirmation = Read-Host "Intune packaging will begin soon.
  Do you want to customize the Acrobat installer before packaging it to an .INTUNEWIN file? (y or n - default is n)"

    if ($confirmation.ToLower() -eq "y") {
        Write-Output "Opening the Adobe Customization Wizard.."
        Start-Sleep -Seconds 1
        Start-Process -FilePath "C:\Program Files (x86)\Adobe\Acrobat Customization Wizard DC\CustWiz.exe"
        Invoke-Item -Path $Installation_directory

        # Prompt the user to resume after customization
        Read-Host "The script is currently paused. Waiting for the user to create custom .mst and .ini files.

        Make sure to save the files in the following directory: $Installation_directory
        Make sure that the .mst file is named 'AcroPro.mst' and the .ini file is named 'setup.ini'.

        If you're ready, you can press Enter to continue..."
    }
    else {}
}
else {
  Write-Output ""
  Write-Output "Customization is currently not possible or cancelled by user,
  script will now use the predefined SETUP and MST files from GitHub..."
  Start-Sleep -Seconds 2
  $setup_ini = "https://github.com/Stensel8/Intune-Deployment-Tool/raw/main/Resources/setup.ini"
  $AcroPro_mst = "https://github.com/Stensel8/Intune-Deployment-Tool/raw/main/Resources/AcroPro.mst"
  (New-Object System.Net.WebClient).DownloadFile($setup_ini, "$Installation_directory\setup.ini")
  (New-Object System.Net.WebClient).DownloadFile($AcroPro_mst, "$Installation_directory\AcroPro.mst")
}





# Start the packaging process
Write-Output "

"
Write-Output "OK, let's start packaging Adobe Acrobat Reader DC..."
Write-Output ""
Start-Process "$Intune_Prep_Path" -ArgumentList "-c $Installation_directory -s $Adobe_source_file -o $Adobe_output_folder -q" -Wait
1..2 | ForEach-Object{"`n"}
Write-Output "Adobe Acrobat Reader packaged succesfully, the package can be found in the INTUNEWIN folder."


    }

    "4" {
        # Execute the code for Choice 4
        Write-Output "You have choosen option 4..."
        Start-Sleep -seconds 2

    $intunePath = "$env:SystemDrive\Intune"
    if  (Test-Path $intunePath) {
    Write-Output "Folder already exists..."

    }
    else {
    New-Item -ItemType directory -Path $intunePath

    }


    $ZipFile = "$intunePath\temp.zip"
    New-Item $ZipFile -ItemType File -Force

    $RepositoryZipUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip"
    # Download the .zip file
    Write-Output 'Starting downloading the GitHub Repository'
    Start-BitsTransfer -Source $RepositoryZipUrl -Destination $ZipFile
    Write-Output 'Download finished, now beginning to package the application...'
    Start-Sleep -seconds 2



# Extract the .zip file
Write-Output 'Starting to unzip the GitHub Repository locally'
Expand-Archive -Path $ZipFile -DestinationPath $intunePath -Force
Write-Output 'Unzip finished'
Remove-Item -Path $ZipFile -Force

Copy-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\* -Destination $intunePath -PassThru
Remove-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\ -Force -Recurse

$CitrixSourcePath = "$env:SystemDrive\Intune\CitrixWorkspace\Source"
$CitrixOutputPath = "$env:SystemDrive\Intune\CitrixWorkspace\Output"
if ( (Test-Path $CitrixSourcePath) -or (Test-Path $CitrixSourcePath))  {
    Write-Output "Folder already exists."
}
else {
    New-Item -ItemType directory -Path $CitrixSourcePath
    New-Item -ItemType directory -Path $CitrixOutputPath
}


$Link = "https://downloadplugins.citrix.com/Windows/CitrixWorkspaceApp.exe"
$fileName = "$env:SystemDrive\Intune\CitrixWorkspace\Source\CitrixWorkspaceApp.exe"

Write-Output 'Starting downloading the Citrix Workspace application...'
Start-BitsTransfer -Source $Link -Destination $fileName
Write-Output 'Download finished, now beginning to package the application...'
Start-Sleep -seconds 2



Start-Process C:\Intune\IntuneWinAppUtil.exe -ArgumentList "-c `"$CitrixSourcePath`" -s CitrixWorkspaceApp.exe -o `"$CitrixOutputPath`""  -Wait
1..2 | ForEach-Object{"`n"}
Write-Output "Citrix Workspace has been packaged successfully!"
 }}

 1..5 | ForEach-Object{"`n"}
# Prompt the user to run again
$RunAgain = Read-Host "Do you want to run the script again? (Y/N)".ToLower()
if ($RunAgain -eq "y") {
    Write-Output "Restarting the script..."
    Start-Sleep -Seconds 3
    Clear-Host
}
else {
    Write-Output "Okay, exiting the script..."
    Start-Sleep -Seconds 3
    Clear-Host
    exit
}
} while ($RunAgain -eq "y")