# Checking if the script is being run with admin rights. If not, the script will automatically be run again as admin.
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
  }


  Write-Host "Menu:"
  1..3 | ForEach-Object{"`n"}

Write-Host "1. Choice 1: Google Chrome (64-bit)"
Write-Host "2. Choice 2: Adobe Acrobat Reader DC - Default image (64-bit)"
#Write-Host "3. Choice 3: Adobe Acrobat Reader DC - Customized image (64-bit)"
Write-Host "4. Choice 4: Citrix Workspace (64-bit)"
$choice = Read-Host "Enter the number of choice"

switch ($choice) {

    "1" {
        # Execute the code for Choice 1
        Write-Host "You have choosen option 1..."
        Start-Sleep -seconds 2
   
    $intunePath = "$env:SystemDrive\Intune"
    if  (Test-Path $intunePath) {
     Write-Host "Folder already exists..."
    } 
    else { 
       New-Item -ItemType directory -Path $intunePath
  
    }


    $ZipFile = "$intunePath\temp.zip"
    New-Item $ZipFile -ItemType File -Force
    
    $RepositoryZipUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip" 
    # Download the .zip file
    Write-Host 'Starting downloading the GitHub Repository'
    Start-BitsTransfer -Source $RepositoryZipUrl -Destination $ZipFile
    Write-Host 'Download finished, now beginning to package the application...'
    Start-Sleep -seconds 2
    

    
    
    # Extract the .zip file
    Write-Host 'Starting unzipping the GitHub Repository locally'
    Expand-Archive -Path $ZipFile -DestinationPath $intunePath -Force
    Write-Host 'Unzip finished'
    Remove-Item -Path $ZipFile -Force 

    Copy-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\* -Destination $intunePath -PassThru
    Remove-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\ -Force -Recurse

    $ChromeSourcePath = "$env:SystemDrive\Intune\GoogleChrome\Source"
    $ChromeOutputPath = "$env:SystemDrive\Intune\GoogleChrome\Output"
    if ( (Test-Path $ChromeSourcePath) -or (Test-Path $ChromeOutputPath))  {
        Write-Host "Folder already exists."
    } 
    else {
        New-Item -ItemType directory -Path $ChromeSourcePath
        New-Item -ItemType directory -Path $ChromeOutputPath
    }

     
    $Link = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi" 
    $fileName = "$env:SystemDrive\Intune\GoogleChrome\Source\GoogleChromeStandaloneEnterprise64.msi"
    
    Write-Host 'Starting downloading the Google Chrome MSI'
    Start-BitsTransfer -Source $Link -Destination $fileName
    Write-Host 'Download finished, now beginning to package the application...'
    Start-Sleep -seconds 2
    


    Start-Process C:\Intune\IntuneWinAppUtil.exe -ArgumentList "-c `"$sourcePath`" -s GoogleChromeStandaloneEnterprise64.msi -o `"$outputPath`"" -Force -Wait
     }

    "2" {
        # Execute code for Choice 2
        Write-Host "You have choosen option 2..."
         $intunePath = "$env:SystemDrive\Intune"

    if  (Test-Path $intunePath) {
     Write-Host "Folder already exists..."
    }
    
    else {
       New-Item -ItemType directory -Path $intunePath
  
    }

    $ZipFile = "$intunePath\temp.zip"
    New-Item $ZipFile -ItemType File -Force

    $RepositoryZipUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip" 
    # Download the .zip file
    Write-Host 'Preparing to download the GitHub Repository'
    Invoke-WebRequest  -Uri $RepositoryZipUrl -OutFile $ZipFile
    Write-Host 'Download finished'

    
    # Extract the .zip file
    Write-Host 'Starting unzipping the GitHub Repository locally'
    Expand-Archive -Path $ZipFile -DestinationPath $intunePath -Force
    Write-Host 'Unzip finished'
    Remove-Item -Path $ZipFile -Force 

    Copy-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\* -Destination $intunePath -PassThru
    Remove-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\ -Force -Recurse

    $sourcePath = "$env:SystemDrive\Intune\Adobe\Source"
    $outputPath = "$env:SystemDrive\Intune\Adobe\Output"
    if ( (Test-Path $sourcePath) -or (Test-Path $outputPath))  {
        Write-Host "Folder already exists.... Using that folder."
    } 
    else {
        New-Item -ItemType directory -Path $sourcePath
        New-Item -ItemType directory -Path $outputPath
    }

     
    $sourceUrl = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300120064/AcroRdrDCx642300120064_nl_NL.exe"
    $fallbackUrl = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300120064/AcroRdrDCx642300120064_nl_NL.exe" 
    $fileName = "$env:SystemDrive\Intune\Adobe\Source\AcroRdrDCx642300120064_nl_NL.exe"
    
     # Download the file using the primary URL
  Write-Output "Downloading Adobe Acrobat Reader DC..."
  try {
      Start-BitsTransfer -Source $sourceUrl -Destination $fileName -ErrorAction
  } catch {
      Write-Output "Failed to download from primary server: $($_.Exception.Message)"
      Write-Output "Downloading Adobe Acrobat Reader DC from fallback server..."
      try {
          Start-BitsTransfer -Source $fallbackUrl -Destination $fileName -ErrorAction Stop
      } catch {
          Write-Output "Failed to download from fallback server, are the downloadservers up-and-running?: $($_.Exception.Message)"
          exit 1
      }
  }

    Write-Host 'Download finished, now beginning to package the application...'
    Start-Sleep -seconds 2

    Start-Process C:\Intune\IntuneWinAppUtil.exe -ArgumentList "-c `"$sourcePath`" -s AcroRdrDCx642300120064_nl_NL.exe -o `"$outputPath`"" -Force -Wait
    }

    "4" {
        # Execute the code for Choice 4
        Write-Host "You have choosen option 4..."
        Start-Sleep -seconds 2

    $intunePath = "$env:SystemDrive\Intune"
    if  (Test-Path $intunePath) {
    Write-Host "Folder already exists..."

    } 
    else { 
    New-Item -ItemType directory -Path $intunePath

    }


    $ZipFile = "$intunePath\temp.zip"
    New-Item $ZipFile -ItemType File -Force

    $RepositoryZipUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip" 
    # Download the .zip file
    Write-Host 'Starting downloading the GitHub Repository'
    Start-BitsTransfer -Source $RepositoryZipUrl -Destination $ZipFile
    Write-Host 'Download finished, now beginning to package the application...'
    Start-Sleep -seconds 2



# Extract the .zip file
Write-Host 'Starting to unzip the GitHub Repository locally'
Expand-Archive -Path $ZipFile -DestinationPath $intunePath -Force
Write-Host 'Unzip finished'
Remove-Item -Path $ZipFile -Force 

Copy-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\* -Destination $intunePath -PassThru
Remove-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\ -Force -Recurse

$CitrixSourcePath = "$env:SystemDrive\Intune\CitrixWorkspace\Source"
$CitrixOutputPath = "$env:SystemDrive\Intune\CitrixWorkspace\Output"
if ( (Test-Path $ChromeSourcePath) -or (Test-Path $ChromeOutputPath))  {
    Write-Host "Folder already exists."
} 
else {
    New-Item -ItemType directory -Path $CitrixSourcePath
    New-Item -ItemType directory -Path $CitrixOutputPath
}

 
$Link = "https://downloads.citrix.com/21794/CitrixWorkspaceApp.exe?__gda__=exp=1683106122~acl=/*~hmac=05b3e00ed3c34409e6dae7e733b9a44aea921fb24d6652c0c68d470ec871dce3" 
$fileName = "$env:SystemDrive\Intune\CitrixWorkspace\Source\CitrixWorkspaceApp.exe"

Write-Host 'Starting downloading the Citrix Workspace application...'
Start-BitsTransfer -Source $Link -Destination $fileName
Write-Host 'Download finished, now beginning to package the application...'
Start-Sleep -seconds 2



Start-Process C:\Intune\IntuneWinAppUtil.exe -ArgumentList "-c `"$CitrixSourcePath`" -s CitrixWorkspaceApp.exe -o `"$CitrixOutputPath`"" -Force -Wait
 }}

 1..5 | ForEach-Object{"`n"}


$null = Read-Host "Press Enter to end the script."

