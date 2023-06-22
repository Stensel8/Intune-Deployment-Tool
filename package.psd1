@{
    Root = 'C:\Users\stent\Documents\GitHub\Acrobat-Intune-Deploy\Scripts\Adobe_Reader_Intuneprep.ps1'
    OutputPath = 'C:\Users\stent\Documents\GitHub\Acrobat-Intune-Deploy\Releases'
    Package = @{
        Enabled = $true
        Obfuscate = $false
        HideConsoleWindow = $false
        DotNetVersion = 'v4.8.1'
        FileVersion = '1.1.4'
        FileDescription = 'Simple packaging tool for Microsoft Intune'
        ProductName = 'IntuneWin-Preptool'
        ProductVersion = '1.1.4'
        Copyright = 'Stensel8'
        RequireElevation = $true
        ApplicationIconPath = 'C:\Users\stent\Documents\GitHub\Acrobat-Intune-Deploy\favicon.ico'
        PackageType = 'Console'

    }
    Bundle = @{
        Enabled = $true
        Modules = $true
        # IgnoredModules = @()
    }
}
