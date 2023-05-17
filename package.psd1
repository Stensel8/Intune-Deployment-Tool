@{
    Root = 'C:\GitHub\Intune-Deployment-Tool\Scripts\Adobe_Reader_Intuneprep.ps1'
    OutputPath = 'C:\GitHub\Intune-Deployment-Tool'
    Package = @{
        Enabled = $true
        Obfuscate = $false
        HideConsoleWindow = $false
        DotNetVersion = 'v4.8.1'
        FileVersion = '1.1.3'
        FileDescription = 'Simple packaging tool for Microsoft Intune'
        ProductName = 'IntuneWin-Preptool'
        ProductVersion = '1.1.3'
        Copyright = 'Stensel8'
        RequireElevation = $true
        ApplicationIconPath = 'C:\Github\Intune-Deployment-Tool\Favicon.ico'
        PackageType = 'Console'

    }
    Bundle = @{
        Enabled = $true
        Modules = $true
        # IgnoredModules = @()
    }
}
