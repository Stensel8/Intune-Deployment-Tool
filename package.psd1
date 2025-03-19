@{
    Root = '.\Scripts\Intune_Tools.ps1'
    OutputPath = '.\Release'
    Package = @{
        Enabled = $true
        FilePath = 'Intune-Deployment-Tool V1.2.0'
        Obfuscate = $false
        HideConsoleWindow = $false
        DotNetVersion = 'v4.8.1'
        FileVersion = '1.2.0'
        FileDescription = 'Simple packaging tool for Microsoft Intune'
        ProductName = 'Intune-Deployment-Tool'
        ProductVersion = '1.2.0'
        Copyright = 'Stensel8'
        RequireElevation = $true
        ApplicationIconPath = '..\..\..\favicon.ico'
        PackageType = 'Console'
    }
    Bundle = @{
        Enabled = $true
        Modules = $true
    }
}
