@{
    Root = 'c:\Users\stent\Documents\GitHub\Acrobat-Intune-Deploy\Scripts\AdobeReaderMSIPrep64bit.ps1'
    OutputPath = 'c:\Users\stent\Documents\GitHub\Acrobat-Intune-Deploy\packages'
    Package = @{
        Enabled = $true
        Obfuscate = $false
        HideConsoleWindow = $false
        DotNetVersion = 'v4.8.1'
        FileVersion = '1.1.1'
        FileDescription = 'Adobe packaging tool for Microsoft Intune'
        ProductName = 'AdobeMSIPreptool'
        ProductVersion = '1.1.1'
        Copyright = 'Stensel8'
        RequireElevation = $true
        ApplicationIconPath = 'C:\Users\stent\Documents\GitHub\Acrobat-Intune-Deploy\Appicon.ico'
        PackageType = 'Console'
    }
    Bundle = @{
        Enabled = $true
        Modules = $true
        # IgnoredModules = @()
    }
}
