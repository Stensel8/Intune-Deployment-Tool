# Check for administrative rights and re-run as admin if needed.
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Clear-Host
[System.Console]::Title = "Intune-Deployment-Tool v1.2.0"
# ================================================================
# Warning Message
# ================================================================
Write-Host ""
Write-Host "=================================================================" -ForegroundColor Red
Write-Host "WARNING: This script downloads and installs files from various sources." -ForegroundColor Red
Write-Host "It is NOT digitally signed. Your antivirus/antimalware software" -ForegroundColor Red
Write-Host "may flag some activities. Use this script at your own risk." -ForegroundColor Red
Write-Host "All code is open source and available for review." -ForegroundColor Red
Write-Host "-----------------------------------------------------------------" -ForegroundColor Red
Write-Host ""
Write-Host ""
Write-Host "WARNING: The GitHub repository for the Win32 Content Prep Tool" -ForegroundColor Red
Write-Host "is still available, but this tool is deprecated. This tool is no longer maintained." -ForegroundColor Red
Write-Host "Please refer to the new Microsoft Store apps approach:" -ForegroundColor Red
Write-Host "  https://learn.microsoft.com/en-us/mem/intune-service/apps/store-apps-microsoft" -ForegroundColor Cyan
Write-Host "Note: The old packaging method for Acrobat still functions, but Microsoft" -ForegroundColor Red
Write-Host "and partners are moving to Microsoft Store apps." -ForegroundColor Red
Write-Host "More info: https://helpx.adobe.com/enterprise/kb/deploy-packages-using-ms-intune.html" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Red
Write-Host ""
Start-Sleep -Seconds 10
Pause

# =======================
# Global Variables Section
# =======================

# Common variables for repository download and extraction.
$global:IntunePath      = "$env:SystemDrive\Intune"
$global:RepoZipUrl      = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip"

# Option 1 - Google Chrome Packaging.
$global:ChromeSourcePath    = "$global:IntunePath\GoogleChrome\Source"
$global:ChromeOutputPath    = "$global:IntunePath\GoogleChrome\Output"
$global:ChromeInstallerUrl  = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
$global:ChromeInstallerPath = "$global:ChromeSourcePath\GoogleChromeStandaloneEnterprise64.msi"

# Option 2 - Adobe Acrobat Packaging.
$global:AcrobatDownloadDir          = "$env:USERPROFILE\Downloads\Adobe-Acrobat64-Setup"
$global:AdobeCustomizationUrlPrimary  = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
$global:AdobeCustomizationUrlFallback = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/misc/CustWiz2200320310_en_US_DC.exe"
$global:AdobeCustomizationOutput      = Join-Path $global:AcrobatDownloadDir "Customization Wizard 2200320310.exe"
$global:AdobeCustomizationMsi         = Join-Path $global:AcrobatDownloadDir "CustWiz.msi"
$global:AcrobatInstallerUrlPrimary    = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2500120432/AcroRdrDCx642500120432_en_US.exe"
$global:AcrobatInstallerUrlFallback   = "https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2500120432/AcroRdrDCx642500120432_en_US.exe"
$global:AcrobatInstallerPath          = Join-Path $global:AcrobatDownloadDir "AcroRdrDCx642500120432_en_US.exe"
$global:AcroSourceFile                = Join-Path $global:AcrobatDownloadDir "Acropro.msi"
$global:AcroOutputFolder              = Join-Path $global:AcrobatDownloadDir "INTUNEWIN"

# Option 3 - 7-Zip Packaging.
$global:SevenZipSourcePath = "$global:IntunePath\7Zip\Source"
$global:SevenZipOutputPath = "$global:IntunePath\7Zip\Output"
$global:SevenZipInstallerUrl = "https://www.7-zip.org/a/7z2409-x64.exe"
$global:SevenZipInstallerPath = "$global:SevenZipSourcePath\7z2409-x64.exe"

# Option 4 - Citrix Workspace Packaging.
$global:CitrixSourcePath    = "$global:IntunePath\CitrixWorkspace\Source"
$global:CitrixOutputPath    = "$global:IntunePath\CitrixWorkspace\Output"
$global:CitrixInstallerUrl  = "https://downloadplugins.citrix.com/Windows/CitrixWorkspaceApp.exe"
$global:CitrixInstallerPath = "$global:CitrixSourcePath\CitrixWorkspaceApp.exe"

# Intune Win32 Content Prep Tool.
$global:IntunePrepToolUrl  = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe"
$global:IntunePrepToolPath = "$env:USERPROFILE\Downloads\IntunePrepTool\IntuneWinAppUtil.exe"

# ============================================
# Function: Download and Extract GitHub Repo
# ============================================
function DownloadAndExtractRepo {
    param (
        [string]$RepoUrl,
        [string]$DestinationPath
    )
    $ZipFile = "$DestinationPath\temp.zip"
    if (-Not (Test-Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    } else {
        Write-Output "Folder already exists: $DestinationPath"
    }
    New-Item -ItemType File -Path $ZipFile -Force | Out-Null

    # Retry logic for downloading the repository
    $maxRetries = 5
    $retryDelay = 5
    $attempt = 1
    while ($attempt -le $maxRetries) {
        try {
            Write-Output "Attempt ${attempt}: Downloading GitHub repository..."
            Start-BitsTransfer -Source $RepoUrl -Destination $ZipFile -ErrorAction Stop
            Write-Output "Download complete."
            break
        }
        catch {
            Write-Output "Attempt $attempt failed: $($_.Exception.Message)"
            if ($attempt -lt $maxRetries) {
                Write-Output "Retrying in $retryDelay seconds..."
                Start-Sleep -Seconds $retryDelay
            } else {
                Write-Host "Failed to download GitHub repository after $maxRetries attempts. Exiting." -ForegroundColor Red
                exit 1
            }
            $attempt++
        }
    }

    Write-Output "Extracting repository..."
    Expand-Archive -Path $ZipFile -DestinationPath $DestinationPath -Force
    Remove-Item -Path $ZipFile -Force
    $ExtractedFolder = Join-Path $DestinationPath "Microsoft-Win32-Content-Prep-Tool-master"
    if (Test-Path $ExtractedFolder) {
        Copy-Item -Path "$ExtractedFolder\*" -Destination $DestinationPath -Recurse -Force
        Remove-Item -Path $ExtractedFolder -Recurse -Force
    }
    Write-Output "Repository extraction complete."
}

# ============================================
# Function: Check and Download Intune Prep Tool if Missing
# ============================================
function CheckAndDownloadIntunePrepTool {
    if (-not (Test-Path $global:IntunePrepToolPath)) {
        Write-Output "IntuneWinAppUtil.exe not found. Downloading now..."
        $IntunePrepFolder = Split-Path $global:IntunePrepToolPath -Parent
        if (-not (Test-Path $IntunePrepFolder)) {
            New-Item -Path $IntunePrepFolder -ItemType Directory -Force | Out-Null
        }
        $maxRetries = 5
        $retryDelay = 5
        $attempt = 1
        while ($attempt -le $maxRetries) {
            try {
                Write-Output "Attempt ${attempt}: Downloading IntuneWinAppUtil.exe..."
                Start-BitsTransfer -Source $global:IntunePrepToolUrl -Destination $global:IntunePrepToolPath -ErrorAction Stop
                Write-Output "Download completed."
                break
            }
            catch {
                Write-Output "Attempt $attempt failed: $($_.Exception.Message)"
                if ($attempt -lt $maxRetries) {
                    Write-Output "Retrying in $retryDelay seconds..."
                    Start-Sleep -Seconds $retryDelay
                } else {
                    Write-Host "Failed to download IntuneWinAppUtil.exe after $maxRetries attempts. Exiting." -ForegroundColor Red
                    exit 1
                }
                $attempt++
            }
        }
    }
}

# ======================
# Main Script Execution
# ======================

# Check for required dependencies.
Write-Host "This script requires the following:
- .NET Framework 4.8 Developer Pack (or higher).
- 7-Zip 23 (or higher)" -ForegroundColor Yellow
Pause
Write-Host "Installing required dependencies..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
    winget install -e --id Microsoft.DotNet.Framework.DeveloperPack_4
    winget install 7zip.7zip
Write-Host ""
Pause
Clear-Host
do {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "         Intune Deployment Tool Menu         " -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1) Google Chrome (64-bit)" -ForegroundColor Green
    Write-Host "2) Adobe Acrobat Reader DC (64-bit)" -ForegroundColor Green
    Write-Host "3) 7-Zip (64-bit)" -ForegroundColor Green
    Write-Host "4) Citrix Workspace (64-bit)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Note: This packaging method is gradually being deprecated." -ForegroundColor White
    Write-Host "Consider using the Microsoft Store for future deployments." -ForegroundColor White
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Cyan
    $choice = Read-Host "Enter the number of your choice"

    switch ($choice) {

        "1" {
            Write-Output "Option 1 selected: Google Chrome packaging..."
            Start-Sleep -Seconds 2

            # Download and extract the repository.
            DownloadAndExtractRepo -RepoUrl $global:RepoZipUrl -DestinationPath $global:IntunePath

            # Create directories for Chrome if they don't exist.
            if (-Not (Test-Path $global:ChromeSourcePath)) {
                New-Item -ItemType Directory -Path $global:ChromeSourcePath -Force | Out-Null
            }
            if (-Not (Test-Path $global:ChromeOutputPath)) {
                New-Item -ItemType Directory -Path $global:ChromeOutputPath -Force | Out-Null
            }

            Write-Output "Downloading Google Chrome MSI..."
            $maxRetries = 5; $retryDelay = 5; $attempt = 1
            while ($attempt -le $maxRetries) {
                try {
                    Write-Output "Attempt $($attempt): Downloading Google Chrome MSI..."
                    Start-BitsTransfer -Source $global:ChromeInstallerUrl -Destination $global:ChromeInstallerPath -ErrorAction Stop
                    Write-Output "Download complete."
                    break
                }
                catch {
                    Write-Output "Attempt $attempt failed: $($_.Exception.Message)"
                    if ($attempt -lt $maxRetries) {
                        Write-Output "Retrying in $retryDelay seconds..."
                        Start-Sleep -Seconds $retryDelay
                    } else {
                        Write-Host "Failed to download Google Chrome MSI after $maxRetries attempts. Exiting." -ForegroundColor Red
                        exit 1
                    }
                    $attempt++
                }
            }

            Write-Output "Packaging application..."
            Start-Sleep -Seconds 2

            # Check for the Intune Prep Tool and download if missing.
            CheckAndDownloadIntunePrepTool

            Start-Process $global:IntunePrepToolPath -ArgumentList "-c `"$global:ChromeSourcePath`" -s GoogleChromeStandaloneEnterprise64.msi -o `"$global:ChromeOutputPath`"" -Wait
            Write-Output "Google Chrome has been packaged successfully!"
        }

        "2" {
            Write-Output "Option 2 selected: Adobe Acrobat Reader DC packaging..."
            Start-Sleep -Seconds 2

            # Prompt for customization preference.
            $customizationChoice = Read-Host "Do you want to customize the Adobe Acrobat installer? (y/n) [Default is n]"
            
            if ($customizationChoice -eq "y") {
                # Download Adobe Customization Wizard with retry logic.
                $maxRetries = 5; $retryDelay = 5; $attempt = 1; $downloadSuccess = $false
                while ($attempt -le $maxRetries) {
                    try {
                        Write-Output "Attempt ${attempt}: Downloading Adobe Customization Wizard from primary server..."
                        Start-BitsTransfer -Source $global:AdobeCustomizationUrlPrimary -Destination $global:AdobeCustomizationOutput -ErrorAction Stop
                        Write-Output "Download succeeded."
                        $downloadSuccess = $true
                        break
                    }
                    catch {
                        Write-Output "Attempt $attempt failed: $($_.Exception.Message)"
                        if ($attempt -lt $maxRetries) {
                            Write-Output "Retrying in $retryDelay seconds..."
                            Start-Sleep -Seconds $retryDelay
                        }
                        $attempt++
                    }
                }
                if (-not $downloadSuccess) {
                    Write-Output "Primary download failed. Trying fallback..."
                    $attempt = 1; $downloadSuccess = $false
                    while ($attempt -le $maxRetries) {
                        try {
                            Write-Output "Attempt ${attempt}: Downloading Adobe Customization Wizard from fallback server..."
                            Start-BitsTransfer -Source $global:AdobeCustomizationUrlFallback -Destination $global:AdobeCustomizationOutput -ErrorAction Stop
                            Write-Output "Fallback download succeeded."
                            $downloadSuccess = $true
                            break
                        }
                        catch {
                            Write-Output "Attempt $attempt failed: $($_.Exception.Message)"
                            if ($attempt -lt $maxRetries) {
                                Write-Output "Retrying in $retryDelay seconds..."
                                Start-Sleep -Seconds $retryDelay
                            }
                            $attempt++
                        }
                    }
                    if (-not $downloadSuccess) {
                        Write-Host "Failed to download Adobe Customization Wizard after $maxRetries attempts on both servers. Exiting." -ForegroundColor Red
                        exit 1
                    }
                }

                # Extract the MSI from the downloaded EXE using 7-Zip.
                & "C:\Program Files\7-Zip\7z.exe" e "$global:AdobeCustomizationOutput" "*.msi" -o"$global:AcrobatDownloadDir" -aoa

                Write-Output "Installing Adobe Customization software silently..."
                $arguments = "/i `"$global:AdobeCustomizationMsi`" /qn /norestart"
                $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -PassThru -Wait

                if ($process.ExitCode -eq 0) {
                    Write-Output "Adobe Customization installation completed successfully."
                } else {
                    Write-Output "Installation failed with exit code: $($process.ExitCode)."
                    Write-Output "You may need to try again or run the customization manually."
                    Start-Sleep -Seconds 2
                }
            }

            # Download Acrobat installation files with retry logic.
            Write-Output "Downloading Acrobat installation files..."
            New-Item -ItemType Directory $global:AcrobatDownloadDir -Force | Out-Null
            Set-Location $global:AcrobatDownloadDir

            $maxRetries = 5; $retryDelay = 5; $attempt = 1; $primarySuccess = $false
            while ($attempt -le $maxRetries) {
                try {
                    Write-Output "Attempt ${attempt}: Downloading Acrobat installer from primary server..."
                    Start-BitsTransfer -Source $global:AcrobatInstallerUrlPrimary -Destination $global:AcrobatInstallerPath -ErrorAction Stop
                    Write-Output "Primary download succeeded."
                    $primarySuccess = $true
                    break
                }
                catch {
                    Write-Output "Attempt $attempt failed: $($_.Exception.Message)"
                    if ($attempt -lt $maxRetries) {
                        Write-Output "Retrying in $retryDelay seconds..."
                        Start-Sleep -Seconds $retryDelay
                    }
                    $attempt++
                }
            }
            if (-not $primarySuccess) {
                Write-Output "Primary server download failed after $maxRetries attempts. Attempting fallback..."
                $attempt = 1; $fallbackSuccess = $false
                while ($attempt -le $maxRetries) {
                    try {
                        Write-Output "Attempt $($attempt): Downloading Acrobat installer from fallback server..."
                        Start-BitsTransfer -Source $global:AcrobatInstallerUrlFallback -Destination $global:AcrobatInstallerPath -ErrorAction Stop
                        Write-Output "Fallback download succeeded."
                        $fallbackSuccess = $true
                        break
                    }
                    catch {
                        Write-Output "Attempt $attempt failed: $($_.Exception.Message)"
                        if ($attempt -lt $maxRetries) {
                            Write-Output "Retrying in $retryDelay seconds..."
                            Start-Sleep -Seconds $retryDelay
                        }
                        $attempt++
                    }
                }
                if (-not $fallbackSuccess) {
                    Write-Host "Failed to download Acrobat installer after $maxRetries attempts on both servers. Exiting." -ForegroundColor Red
                    exit 1
                }
            }

            Write-Output "Extracting the Acrobat installer EXE..."
            Start-Process -FilePath $global:AcrobatInstallerPath -ArgumentList "-sfx_o`"$global:AcrobatDownloadDir`" -sfx_ne -quiet" -Wait
            Write-Output "Extraction complete."

            Start-Sleep -Seconds 3

            # Check for the Intune Prep Tool and download if missing.
            CheckAndDownloadIntunePrepTool

            Write-Output "Cleaning up temporary installation files..."
            Remove-Item -Path $global:AcrobatInstallerPath -Force -ErrorAction SilentlyContinue
            Remove-Item -Path $global:AdobeCustomizationMsi -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1

            Write-Output "Adobe Acrobat installation files are in: $global:AcrobatDownloadDir"
            Start-Sleep -Seconds 2

            if ($customizationChoice -eq "y") {
                $confirmation = Read-Host "Do you want to run the customization wizard before packaging? (y/n, default is n)"
                if ($confirmation.ToLower() -eq "y") {
                    Write-Output "Opening Adobe Customization Wizard..."
                    Start-Sleep -Seconds 1
                    Start-Process -FilePath "C:\Program Files (x86)\Adobe\Acrobat Customization Wizard DC\CustWiz.exe"
                    Invoke-Item -Path $global:AcrobatDownloadDir
                    Read-Host "Press Enter when you have completed customization. Ensure your .mst file is 'AcroPro.mst' and your .ini file is 'setup.ini'."
                }
            }
            else {
                Write-Output "Customization skipped. Continuing with default settings."
                Start-Sleep -Seconds 2
            }

            Write-Output "Packaging Adobe Acrobat Reader..."
            Start-Process $global:IntunePrepToolPath -ArgumentList "-c $global:AcrobatDownloadDir -s $global:AcroSourceFile -o $global:AcroOutputFolder -q" -Wait
            Write-Output "Adobe Acrobat Reader has been packaged successfully!"
        }

        "3" {
            Write-Output "Option 3 selected: 7-Zip packaging..."
            Start-Sleep -Seconds 2

            # Create directories for 7-Zip if they don't exist.
            if (-Not (Test-Path $global:SevenZipSourcePath)) {
                New-Item -ItemType Directory -Path $global:SevenZipSourcePath -Force | Out-Null
            }
            if (-Not (Test-Path $global:SevenZipOutputPath)) {
                New-Item -ItemType Directory -Path $global:SevenZipOutputPath -Force | Out-Null
            }

            # Download 7-Zip installer with retry logic.
            $maxRetries = 5; $retryDelay = 5; $attempt = 1
            while ($attempt -le $maxRetries) {
                try {
                    Write-Output "Attempt ${attempt}: Downloading 7-Zip installer..."
                    Start-BitsTransfer -Source $global:SevenZipInstallerUrl -Destination $global:SevenZipInstallerPath -ErrorAction Stop
                    Write-Output "Download succeeded."
                    break
                }
                catch {
                    Write-Output "Attempt $attempt failed: $($_.Exception.Message)"
                    if ($attempt -lt $maxRetries) {
                        Write-Output "Retrying in $retryDelay seconds..."
                        Start-Sleep -Seconds $retryDelay
                    } else {
                        Write-Host "Failed to download 7-Zip installer after $maxRetries attempts. Exiting." -ForegroundColor Red
                        exit 1
                    }
                    $attempt++
                }
            }

            Write-Output "Packaging 7-Zip..."
            Start-Sleep -Seconds 2

            # Check for the Intune Prep Tool and download if missing.
            CheckAndDownloadIntunePrepTool

            Start-Process $global:IntunePrepToolPath -ArgumentList "-c `"$global:SevenZipSourcePath`" -s 7z2409-x64.exe -o `"$global:SevenZipOutputPath`"" -Wait
            Write-Output "7-Zip has been packaged successfully!"
        }

        "4" {
            Write-Output "Option 4 selected: Citrix Workspace packaging..."
            Start-Sleep -Seconds 2

            # Download and extract the repository.
            DownloadAndExtractRepo -RepoUrl $global:RepoZipUrl -DestinationPath $global:IntunePath

            # Create directories for Citrix Workspace if they don't exist.
            if (-Not (Test-Path $global:CitrixSourcePath)) {
                New-Item -ItemType Directory -Path $global:CitrixSourcePath -Force | Out-Null
            }
            if (-Not (Test-Path $global:CitrixOutputPath)) {
                New-Item -ItemType Directory -Path $global:CitrixOutputPath -Force | Out-Null
            }

            # Download Citrix Workspace installer with retry logic.
            $maxRetries = 5; $retryDelay = 5; $attempt = 1
            while ($attempt -le $maxRetries) {
                try {
                    Write-Output "Attempt ${attempt}: Downloading Citrix Workspace installer..."
                    Start-BitsTransfer -Source $global:CitrixInstallerUrl -Destination $global:CitrixInstallerPath -ErrorAction Stop
                    Write-Output "Download succeeded."
                    break
                }
                catch {
                    Write-Output "Attempt $attempt failed: $($_.Exception.Message)"
                    if ($attempt -lt $maxRetries) {
                        Write-Output "Retrying in $retryDelay seconds..."
                        Start-Sleep -Seconds $retryDelay
                    } else {
                        Write-Host "Failed to download Citrix Workspace installer after $maxRetries attempts. Exiting." -ForegroundColor Red
                        exit 1
                    }
                    $attempt++
                }
            }

            Write-Output "Packaging application..."
            Start-Sleep -Seconds 2

            # Check for the Intune Prep Tool and download if missing.
            CheckAndDownloadIntunePrepTool

            Start-Process $global:IntunePrepToolPath -ArgumentList "-c `"$global:CitrixSourcePath`" -s CitrixWorkspaceApp.exe -o `"$global:CitrixOutputPath`"" -Wait
            Write-Output "Citrix Workspace has been packaged successfully!"
        }

        default {
            Write-Output "Invalid choice. Please select a valid option."
        }
    }

    Write-Output ""
    $RunAgain = Read-Host "Do you want to run the script again? (y/n)"
} while ($RunAgain.ToLower() -eq "y")

Write-Output "Exiting the script. Goodbye!"
