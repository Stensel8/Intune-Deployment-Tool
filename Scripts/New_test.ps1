Write-Host "Menu:"
Write-Host "1. Choice 1"
Write-Host "2. Choice 2"
Write-Host "3. Choice 3"
$choice = Read-Host "Enter your choice"

switch ($choice) {
    "1" {
        # Execute code for Choice 1
        Write-Host "You chose Choice 1"
   
    $intunePath = "$env:SystemDrive\Intune"
    if  (Test-Path $intunePath) {
     Write-Host "Folder already exists."
    } 
    else {
       New-Item -ItemType directory -Path $intunePath
  
    }


    $ZipFile = "$intunePath\temp.zip"
    New-Item $ZipFile -ItemType File -Force

    $RepositoryZipUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip" 
    # download the zip 
    Write-Host 'Starting downloading the GitHub Repository'
    Invoke-WebRequest  -Uri $RepositoryZipUrl -OutFile $ZipFile
    Write-Host 'Download finished'

    
    #Extract Zip File
    Write-Host 'Starting unzipping the GitHub Repository locally'
    Expand-Archive -Path $ZipFile -DestinationPath $intunePath -Force
    Write-Host 'Unzip finished'
    Remove-Item -Path $ZipFile -Force 

    Copy-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\* -Destination $intunePath -PassThru
    Remove-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\ -Force -Recurse

    $sourcePath = "$env:SystemDrive\Intune\GoogleChrome\Source"
    $outputPath = "$env:SystemDrive\Intune\GoogleChrome\Output"
    if ( (Test-Path $sourcePath) -or (Test-Path $outputPath))  {
        Write-Host "Folder already exists."
    } 
    else {
        New-Item -ItemType directory -Path $sourcePath
        New-Item -ItemType directory -Path $outputPath
    }

     
	$webclient = New-Object System.Net.WebClient
    $Link = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi" 
    $fileName = "$env:SystemDrive\Intune\GoogleChrome\Source\GoogleChromeStandaloneEnterprise64.msi"
    $webclient.DownloadFile($Link, $fileName)


    Start-Process C:\Intune\IntuneWinAppUtil.exe -ArgumentList "-c `"$sourcePath`" -s GoogleChromeStandaloneEnterprise64.msi -o `"$outputPath`""


     }
    "2" {
        # Execute code for Choice 2
        Write-Host "You chose Choice 2"

         $intunePath = "$env:SystemDrive\Intune"
    if  (Test-Path $intunePath) {
     Write-Host "Folder already exists."
    } 
    else {
       New-Item -ItemType directory -Path $intunePath
  
    }


    $ZipFile = "$intunePath\temp.zip"
    New-Item $ZipFile -ItemType File -Force

    $RepositoryZipUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip" 
    # download the zip 
    Write-Host 'Starting downloading the GitHub Repository'
    Invoke-WebRequest  -Uri $RepositoryZipUrl -OutFile $ZipFile
    Write-Host 'Download finished'

    
    #Extract Zip File
    Write-Host 'Starting unzipping the GitHub Repository locally'
    Expand-Archive -Path $ZipFile -DestinationPath $intunePath -Force
    Write-Host 'Unzip finished'
    Remove-Item -Path $ZipFile -Force 

    Copy-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\* -Destination $intunePath -PassThru
    Remove-Item -Path C:\Intune\Microsoft-Win32-Content-Prep-Tool-master\ -Force -Recurse

    $sourcePath = "$env:SystemDrive\Intune\Adobe\Source"
    $outputPath = "$env:SystemDrive\Intune\Adobe\Output"
    if ( (Test-Path $sourcePath) -or (Test-Path $outputPath))  {
        Write-Host "Folder already exists."
    } 
    else {
        New-Item -ItemType directory -Path $sourcePath
        New-Item -ItemType directory -Path $outputPath
    }

     
	$webclient = New-Object System.Net.WebClient
    $Link = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2300120064/AcroRdrDC2300120064_nl_NL.exe" 
    $fileName = "$env:SystemDrive\Intune\Adobe\Source\AcroRdrDC2300120064_nl_NL.exe"
    $webclient.DownloadFile($Link, $fileName)


    Start-Process C:\Intune\IntuneWinAppUtil.exe -ArgumentList "-c `"$sourcePath`" -s AcroRdrDC2300120064_nl_NL.exe -o `"$outputPath`""


    }
    "3" {
        # Execute code for Choice 3
        Write-Host "You chose Choice 3"
    }
    Default {
        # Execute code if the user enters an invalid choice
        Write-Host "Invalid choice"
    } 
}

