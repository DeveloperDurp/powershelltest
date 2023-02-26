##Import Functions
Measure-Command -Expression {
    $FunctionsToImport = @(
        "Get-CheckBoxes.ps1",
        "Get-DarkMode.ps1",
        "Get-FormVariables.ps1",
        "Get-InstallerProcess.ps1",
        "Install-Choco.ps1",
        "Install-ProgramWinget.ps1",
        "Install-Winget.ps1",
        "Invoke-Runspace.ps1",
        "Invoke-WinTweaks.ps1",
        "Invoke-WinUtilImpex.ps1",
        "Invoke-WinUtilScript.ps1",
        "Remove-WinUtilAPPX.ps1",
        "Set-DarkMode.ps1",
        "Set-Presets.ps1",
        "Set-WinUtilDNS.ps1",
        "Set-WinUtilRegistry.ps1",
        "Set-WinUtilScheduledTask.ps1",
        "Set-WinUtilService.ps1",
        "Switch-Tab.ps1",
        "Test-PackageManager.ps1",
        "Update-ProgramWinget.ps1"
    )
    $scripts = @{}
    
    $FunctionsToImport | ForEach-Object {
        $scripts.$psitem = [System.Net.WebClient]::new().DownloadStringTaskAsync("https://raw.githubusercontent.com/DeveloperDurp/powershelltest/main/functions/$psitem")
    }
    
    $FunctionsToImport | ForEach-Object {
        . ([scriptblock]::Create($($scripts.$psitem.GetAwaiter().GetResult())))   
    }    
} | select TotalMilliseconds


Measure-Command -Expression { . ./test.ps1} | select TotalMilliseconds