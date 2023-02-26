##Import Functions
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

    $ConfigsToLoad | ForEach-Object {
        $functions = [System.Net.WebClient]::new().DownloadStringTaskAsync("https://raw.githubusercontent.com/ChrisTitusTech/winutil/$($Sync.BranchToUse)/config/$psitem.json")
    }

    $ConfigsToLoad | ForEach-Object {
        $sync.configs["$psitem"] = ConvertFrom-Json ($sync.configs["$psitem"].GetAwaiter().GetResult())
    }

try {
    $PublicFunctions = Get-ChildItem $FunctionPathPublic | ForEach-Object {
        [System.IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8) + [Environment]::NewLine
    }

    $PrivateFunctions = Get-ChildItem $FunctionPathPrivate | ForEach-Object {
        [System.IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8) + [Environment]::NewLine
    }

    . ([scriptblock]::Create($PublicFunctions))
    . ([scriptblock]::Create($PrivateFunctions))
}

catch {
    $FunctionListPublic = Get-ChildItem $FunctionPathPublic -Name
    $FunctionListPrivate = Get-ChildItem $FunctionPathPrivate -Name

    ForEach ($Function in $FunctionListPublic) {
        . ($FunctionPathPublic + $Function)
    }

    ForEach ($Function in $FunctionListPrivate) {
        . ($FunctionPathPrivate + $Function)
    }
}

##Import Support Files
#Save the current value for Path in the $p variable.
$p = [Environment]::GetEnvironmentVariable("Path")
#Add the new path to the $p variable. Begin with a semi-colon separator.
$FunctionPath = $PSScriptRoot + "\Support\"
$p += ";$FunctionPath"
#Add the paths in $p to the PSModulePath value.
[Environment]::SetEnvironmentVariable("Path", $p)