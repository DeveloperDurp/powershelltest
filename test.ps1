
Function Get-FormVariables {
    #If ($global:ReadmeDisplay -ne $true) { Write-Host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow; $global:ReadmeDisplay = $true }


    Write-Host ""
    Write-Host "    CCCCCCCCCCCCCTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT   "
    Write-Host " CCC::::::::::::CT:::::::::::::::::::::TT:::::::::::::::::::::T   "
    Write-Host "CC:::::::::::::::CT:::::::::::::::::::::TT:::::::::::::::::::::T  "
    Write-Host "C:::::CCCCCCCC::::CT:::::TT:::::::TT:::::TT:::::TT:::::::TT:::::T "
    Write-Host "C:::::C       CCCCCCTTTTTT  T:::::T  TTTTTTTTTTTT  T:::::T  TTTTTT"
    Write-Host "C:::::C                     T:::::T                T:::::T        "
    Write-Host "C:::::C                     T:::::T                T:::::T        "
    Write-Host "C:::::C                     T:::::T                T:::::T        "
    Write-Host "C:::::C                     T:::::T                T:::::T        "
    Write-Host "C:::::C                     T:::::T                T:::::T        "
    Write-Host "C:::::C                     T:::::T                T:::::T        "
    Write-Host "C:::::C       CCCCCC        T:::::T                T:::::T        "
    Write-Host "C:::::CCCCCCCC::::C      TT:::::::TT            TT:::::::TT       "
    Write-Host "CC:::::::::::::::C       T:::::::::T            T:::::::::T       "
    Write-Host "CCC::::::::::::C         T:::::::::T            T:::::::::T       "
    Write-Host "  CCCCCCCCCCCCC          TTTTTTTTTTT            TTTTTTTTTTT       "
    Write-Host ""
    Write-Host "====Chris Titus Tech====="
    Write-Host "=====Windows Toolbox====="


    #====DEBUG GUI Elements====

    #Write-Host "Found the following interactable elements from our form" -ForegroundColor Cyan
    #get-variable WPF*
}

Function Get-CheckBoxes {

    <#

        .DESCRIPTION
        Function is meant to find all checkboxes that are checked on the specefic tab and input them into a script.

        Outputed data will be the names of the checkboxes that were checked

        .EXAMPLE

        Get-CheckBoxes "WPFInstall"

    #>

    Param(
        $Group,
        [boolean]$unCheck = $true
    )


    $Output = New-Object System.Collections.Generic.List[System.Object]

    if($Group -eq "WPFInstall"){
        $CheckBoxes = get-variable | Where-Object {$psitem.name -like "WPFInstall*" -and $psitem.value.GetType().name -eq "CheckBox"}
        Foreach ($CheckBox in $CheckBoxes){
            if($CheckBox.value.ischecked -eq $true){
                $sync.configs.applications.$($CheckBox.name).winget -split ";" | ForEach-Object {
                    $Output.Add($psitem)
                }
                if ($uncheck -eq $true){
                    $CheckBox.value.ischecked = $false
                }
                
            }
        }
    }
    if($Group -eq "WPFTweaks"){
        $CheckBoxes = get-variable | Where-Object {$psitem.name -like "WPF*Tweaks*" -and $psitem.value.GetType().name -eq "CheckBox"}
        Foreach ($CheckBox in $CheckBoxes){
            if($CheckBox.value.ischecked -eq $true){
                $Output.Add($Checkbox.Name)
                
                if ($uncheck -eq $true){
                    $CheckBox.value.ischecked = $false
                }
            }
        }
    }

    Write-Output $($Output | Select-Object -Unique)
}

function Set-Presets {
    <#

        .DESCRIPTION
        Meant to make settings presets easier in the tweaks tab. Will pull the data from config/preset.json

    #>

    param(
        $preset,
        [bool]$imported = $false
    )
    if($imported -eq $true){
        $CheckBoxesToCheck = $preset
    }
    Else{
        $CheckBoxesToCheck = $sync.configs.preset.$preset
    }

    #Uncheck all
    get-variable | Where-Object {$_.name -like "*tweaks*"} | ForEach-Object {
        if ($psitem.value.gettype().name -eq "CheckBox"){
            $CheckBox = Get-Variable $psitem.Name
            if ($CheckBoxesToCheck -contains $CheckBox.name){
                $checkbox.value.ischecked = $true
            }
            else{$checkbox.value.ischecked = $false}
        }
    }

}

function Switch-Tab {

    <#
    
        .DESCRIPTION
        Sole purpose of this fuction reduce duplicated code for switching between tabs. 
    
    #>

    Param ($ClickedTab)
    $Tabs = Get-Variable WPFTab?BT
    $TabNav = Get-Variable WPFTabNav
    $x = [int]($ClickedTab -replace "WPFTab","" -replace "BT","") - 1

    0..($Tabs.Count -1 ) | ForEach-Object {
        
        if ($x -eq $psitem){
            $TabNav.value.Items[$psitem].IsSelected = $true
        }
        else{
            $TabNav.value.Items[$psitem].IsSelected = $false
        }
    }
}

function Get-InstallerProcess {
    <#
    
        .DESCRIPTION
        Meant to check for running processes and will return a boolean response
    
    #>

    param($Process)

    if ($Null -eq $Process){
        return $false
    }
    if (Get-Process -Id $Process.Id -ErrorAction SilentlyContinue){
        return $true
    }
    return $false
}

Function Install-ProgramWinget {

    <#
    
        .DESCRIPTION
        This will install programs via Winget using a new powershell.exe instance to prevent the GUI from locking up.

        Note the triple quotes are required any time you need a " in a normal script block.
    
    #>

    param($ProgramsToInstall)

    [ScriptBlock]$wingetinstall = {
        param($ProgramsToInstall)

        $host.ui.RawUI.WindowTitle = """Winget Install"""

        $x = 0
        $count = $($ProgramsToInstall -split """,""").Count

        Write-Progress -Activity """Installing Applications""" -Status """Starting""" -PercentComplete 0
    
        Write-Host """`n`n`n`n`n`n"""
        
        Start-Transcript $ENV:TEMP\winget.log -Append
    
        Foreach ($Program in $($ProgramsToInstall -split """,""")){
    
            Write-Progress -Activity """Installing Applications""" -Status """Installing $Program $($x + 1) of $count""" -PercentComplete $($x/$count*100)
            Start-Process -FilePath winget -ArgumentList """install -e --accept-source-agreements --accept-package-agreements --silent $Program""" -NoNewWindow -Wait;
            $X++
        }

        Write-Progress -Activity """Installing Applications""" -Status """Finished""" -Completed
        Write-Host """`n`nAll Programs have been installed"""
        Pause
    }

    $global:WinGetInstall = Start-Process -Verb runas powershell -ArgumentList "-command invoke-command -scriptblock {$wingetinstall} -argumentlist '$($ProgramsToInstall -join ",")'" -PassThru

}

Function Update-ProgramWinget {

    <#
    
        .DESCRIPTION
        This will update programs via Winget using a new powershell.exe instance to prevent the GUI from locking up.
    
    #>

    [ScriptBlock]$wingetinstall = {

        $host.ui.RawUI.WindowTitle = """Winget Install"""

        Start-Transcript $ENV:TEMP\winget-update.log -Append
        winget upgrade --all

        Pause
    }

    $global:WinGetInstall = Start-Process -Verb runas powershell -ArgumentList "-command invoke-command -scriptblock {$wingetinstall} -argumentlist '$($ProgramsToInstall -join ",")'" -PassThru

}

function Test-PackageManager {
    Param(
        [System.Management.Automation.SwitchParameter]$winget,
        [System.Management.Automation.SwitchParameter]$choco
    )

    if($winget){
        if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe) {
            return $true
        }
    }

    if($choco){
        if ((Get-Command -Name choco -ErrorAction Ignore) -and ($chocoVersion = (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion)){
            return $true
        }
    }

    return $false
}

function Install-Winget {

    <#
    
        .DESCRIPTION
        Function is meant to ensure winget is installed 
    
    #>

    Try{
        Write-Host "Checking if Winget is Installed..."
        if (Test-PackageManager -winget) {
            #Checks if winget executable exists and if the Windows Version is 1809 or higher
            Write-Host "Winget Already Installed"
            return
        }

        #Gets the computer's information
        if ($null -eq $sync.ComputerInfo){
            $ComputerInfo = Get-ComputerInfo -ErrorAction Stop
        }
        Else {
            $ComputerInfo = $sync.ComputerInfo
        }

        if (($ComputerInfo.WindowsVersion) -lt "1809") {
            #Checks if Windows Version is too old for winget
            Write-Host "Winget is not supported on this version of Windows (Pre-1809)"
            return
        }

        #Gets the Windows Edition
        $OSName = if ($ComputerInfo.OSName) {
            $ComputerInfo.OSName
        }else {
            $ComputerInfo.WindowsProductName
        }

        if (((($OSName.IndexOf("LTSC")) -ne -1) -or ($OSName.IndexOf("Server") -ne -1)) -and (($ComputerInfo.WindowsVersion) -ge "1809")) {

            Write-Host "Running Alternative Installer for LTSC/Server Editions"

            # Switching to winget-install from PSGallery from asheroto
            # Source: https://github.com/asheroto/winget-installer

            Start-Process powershell.exe -Verb RunAs -ArgumentList "-command irm https://raw.githubusercontent.com/ChrisTitusTech/winutil/$BranchToUse/winget.ps1 | iex | Out-Host" -WindowStyle Normal -ErrorAction Stop

            if(!(Test-PackageManager -winget)){
                break
            }
        }

        else {
            #Installing Winget from the Microsoft Store
            Write-Host "Winget not found, installing it now."
            Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
            $nid = (Get-Process AppInstaller).Id
            Wait-Process -Id $nid

            if(!(Test-PackageManager -winget)){
                break
            }
        }
        Write-Host "Winget Installed"
    }
    Catch{
        throw [WingetFailedInstall]::new('Failed to install')
    }

    # Check if chocolatey is installed and get its version

}

function Install-Choco {

    <#
    
        .DESCRIPTION
        Function is meant to ensure Choco is installed 
    
    #>

    try{
        Write-Host "Checking if Chocolatey is Installed..."

        if((Test-PackageManager -choco)){
            Write-Host "Chocolatey Already Installed"
            return
        }
    
        Write-Host "Seems Chocolatey is not installed, installing now?"
        #Let user decide if he wants to install Chocolatey
        $confirmation = Read-Host "Are you Sure You Want To Proceed:(y/n)"
        if ($confirmation -eq 'y') {
            Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -ErrorAction Stop
            powershell choco feature enable -n allowGlobalConfirmation
        }
    }
    Catch{
        throw [ChocoFailedInstall]::new('Failed to install')
    }

}

function Invoke-Runspace {

    <#
    
        .DESCRIPTION
        Simple function to make it easier to invoke a runspace from inside the script. 

        .EXAMPLE

        $params = @{
            ScriptBlock = $sync.ScriptsInstallPrograms
            ArgumentList = "Installadvancedip,Installbitwarden"
            Verbose = $true
        }

        Invoke-Runspace @params
    
    #>

    [CmdletBinding()]
    Param (
        $ScriptBlock,
        $ArgumentList
    ) 

    $Script = [PowerShell]::Create().AddScript($ScriptBlock).AddArgument($ArgumentList)

    $Script.Runspace = $runspace
    $Script.BeginInvoke()
}

function Invoke-WinTweaks {
    <#
    
        .DESCRIPTION
        This function converts all the values from the tweaks.json and routes them to the appropriate function
    
    #>

    param($CheckBox)
    if($sync.configs.tweaks.$CheckBox.registry){
        $sync.configs.tweaks.$CheckBox.registry | ForEach-Object {
            Set-WinUtilRegistry -Name $psitem.Name -Path $psitem.Path -Type $psitem.Type -Value $psitem.Value 
        }
    }
    if($sync.configs.tweaks.$CheckBox.ScheduledTask){
        $sync.configs.tweaks.$CheckBox.ScheduledTask | ForEach-Object {
            Set-WinUtilScheduledTask -Name $psitem.Name -State $psitem.State
        }
    }
    if($sync.configs.tweaks.$CheckBox.service){
        $sync.configs.tweaks.$CheckBox.service | ForEach-Object {
            Set-WinUtilService -Name $psitem.Name -StartupType $psitem.StartupType
        }
    }
    if($sync.configs.tweaks.$CheckBox.appx){
        $sync.configs.tweaks.$CheckBox.appx | ForEach-Object {
            Remove-WinUtilAPPX -Name $psitem
        }
    }
    if($sync.configs.tweaks.$CheckBox.InvokeScript){
        $sync.configs.tweaks.$CheckBox.InvokeScript | ForEach-Object {
            $Scriptblock = [scriptblock]::Create($psitem)
            Invoke-WinUtilScript -ScriptBlock $scriptblock -Name $CheckBox
        }
    }
}

function Set-WinUtilRegistry {
    <#
    
        .DESCRIPTION
        This function will make all modifications to the registry

        .EXAMPLE

        Set-WinUtilRegistry -Name "PublishUserActivities" -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Type "DWord" -Value "0"
    
    #>    
    param (
        $Name,
        $Path,
        $Type,
        $Value
    )

    Try{      
        if(!(Test-Path 'HKU:\')){New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS}

        If (!(Test-Path $Path)) {
            Write-Host "$Path was not found, Creating..."
            New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
        }

        Write-Host "Set $Path\$Name to $Value"
        Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value -Force -ErrorAction Stop | Out-Null
    }
    Catch [System.Security.SecurityException] {
        Write-Warning "Unable to set $Path\$Name to $Value due to a Security Exception"
    }
    Catch [System.Management.Automation.ItemNotFoundException] {
        Write-Warning $psitem.Exception.ErrorRecord
    }
    Catch{
        Write-Warning "Unable to set $Name due to unhandled exception"
        Write-Warning $psitem.Exception.StackTrace
    }
}

Function Set-WinUtilService {
    <#
    
        .DESCRIPTION
        This function will change the startup type of services and start/stop them as needed

        .EXAMPLE

        Set-WinUtilService -Name "HomeGroupListener" -StartupType "Manual"
    
    #>   
    param (
        $Name,
        $StartupType
    )
    Try{
        Write-Host "Setting Services $Name to $StartupType"
        Set-Service -Name $Name -StartupType $StartupType -ErrorAction Stop

        if($StartupType -eq "Disabled"){
            Write-Host "Stopping $Name"
            Stop-Service -Name $Name -Force -ErrorAction Stop
        }
        if($StartupType -eq "Enabled"){
            Write-Host "Starting $Name"
            Start-Service -Name $Name -Force -ErrorAction Stop
        }
    }
    Catch [System.Exception]{
        if($psitem.Exception.Message -like "*Cannot find any service with service name*" -or 
           $psitem.Exception.Message -like "*was not found on computer*"){
            Write-Warning "Service $name was not Found"
        }
        Else{
            Write-Warning "Unable to set $Name due to unhandled exception"
            Write-Warning $psitem.Exception.Message
        }
    }
    Catch{
        Write-Warning "Unable to set $Name due to unhandled exception"
        Write-Warning $psitem.Exception.StackTrace
    }
}

function Invoke-WinUtilScript {
    <#
    
        .DESCRIPTION
        This function will run a seperate powershell script. Meant for things that can't be handled with the other functions

        .EXAMPLE

        $Scriptblock = [scriptblock]::Create({"Write-output 'Hello World'"})
        Invoke-WinUtilScript -ScriptBlock $scriptblock -Name "Hello World"
    
    #>
    param (
        $Name,
        [scriptblock]$scriptblock
    )

    Try{
        Start-Process powershell.exe -Verb runas -ArgumentList "-Command  $scriptblock" -Wait -ErrorAction Stop
    }
    Catch{
        Write-Warning "Unable to run script for $name due to unhandled exception"
        Write-Warning $psitem.Exception.StackTrace 
    }
}

function Set-WinUtilScheduledTask {
    <#
    
        .DESCRIPTION
        This function will enable/disable the provided Scheduled Task

        .EXAMPLE

        Set-WinUtilScheduledTask -Name "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" -State "Disabled"
    
    #>
    param (
        $Name,
        $State
    )

    Try{
        if($State -eq "Disabled"){
            Write-Host "Disabling Scheduled Task $Name"
            Disable-ScheduledTask -TaskName $Name -ErrorAction Stop
        }
        if($State -eq "Enabled"){
            Write-Host "Enabling Scheduled Task $Name"
            Enable-ScheduledTask -TaskName $Name -ErrorAction Stop
        }
    }
    Catch [System.Exception]{
        if($psitem.Exception.Message -like "*The system cannot find the file specified*"){
            Write-Warning "Scheduled Task $name was not Found"
        }
        Else{
            Write-Warning "Unable to set $Name due to unhandled exception"
            Write-Warning $psitem.Exception.Message
        }
    }
    Catch{
        Write-Warning "Unable to run script for $name due to unhandled exception"
        Write-Warning $psitem.Exception.StackTrace 
    }
}

function Remove-WinUtilAPPX {
    <#
    
        .DESCRIPTION
        This function will remove any of the provided APPX names

        .EXAMPLE

        Remove-WinUtilAPPX -Name "Microsoft.Microsoft3DViewer"
    
    #>
    param (
        $Name
    )

    Try{
        Write-Host "Removing $Name"
        Get-AppxPackage "*$Name*" | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*$Name*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
    Catch [System.Exception] {
        if($psitem.Exception.Message -like "*The requested operation requires elevation*"){
            Write-Warning "Unable to uninstall $name due to a Security Exception"
        }
        Else{
            Write-Warning "Unable to uninstall $name due to unhandled exception"
            Write-Warning $psitem.Exception.StackTrace 
        }
    }
    Catch{
        Write-Warning "Unable to uninstall $name due to unhandled exception"
        Write-Warning $psitem.Exception.StackTrace 
    }
}

function Set-WinUtilDNS {
    <#
    
        .DESCRIPTION
        This function will set the DNS of all interfaces that are in the "Up" state. It will lookup the values from the DNS.Json file

        .EXAMPLE

        Set-WinUtilDNS -DNSProvider "google"
    
    #>
    param($DNSProvider)
    if($DNSProvider -eq "Default"){return}
    Try{
        $Adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
        Write-Host "Ensuring DNS is set to $DNSProvider on the following interfaces"
        Write-Host $($Adapters | Out-String)

        Foreach ($Adapter in $Adapters){
            if($DNSProvider -eq "DHCP"){
                Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ResetServerAddresses
            }
            Else{
                Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ServerAddresses ("$($sync.configs.dns.$DNSProvider.Primary)", "$($sync.configs.dns.$DNSProvider.Secondary)")
            }
        }
    }
    Catch{
        Write-Warning "Unable to set DNS Provider due to an unhandled exception"
        Write-Warning $psitem.Exception.StackTrace 
    }
}

function Invoke-WinUtilImpex {
    <#
    
        .DESCRIPTION
        This function handles importing and exporting of the checkboxes checked for the tweaks section

        .EXAMPLE

        Invoke-WinUtilImpex -type "export"
    
    #>
    param($type)

    if ($type -eq "export"){
        $FileBrowser = New-Object System.Windows.Forms.SaveFileDialog
    }
    if ($type -eq "import"){
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog 
    }

    $FileBrowser.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $FileBrowser.Filter = "JSON Files (*.json)|*.json"
    $FileBrowser.ShowDialog() | Out-Null

    if($FileBrowser.FileName -eq ""){
        return
    }
    
    if ($type -eq "export"){
        $jsonFile = Get-CheckBoxes WPFTweaks -unCheck $false
        $jsonFile | ConvertTo-Json | Out-File $FileBrowser.FileName -Force
    }
    if ($type -eq "import"){
        $jsonFile = Get-Content $FileBrowser.FileName | ConvertFrom-Json
        Set-Presets -preset $jsonFile -imported $true
    }
}

Function Get-DarkMode {
    $app = (Get-ItemProperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize').AppsUseLightTheme
    $system = (Get-ItemProperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize').SystemUsesLightTheme
    if($app -eq 0 -and $system -eq 0){
        return $true
    } 
    else{
        return $false
    }
}

Function Set-DarkMode {
    Param($DarkMoveEnabled)
    Try{
        if ($DarkMoveEnabled -eq $false){
            Write-Host "Enabling Dark Mode"
            $DarkMoveValue = 0
        }
        else {
            Write-Host "Disabling Dark Mode"
            $DarkMoveValue = 1
        }
    
        $Theme = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        Set-ItemProperty -Path $Theme -Name AppsUseLightTheme -Value $DarkMoveValue
        Set-ItemProperty -Path $Theme -Name SystemUsesLightTheme -Value $DarkMoveValue
    }
    Catch [System.Security.SecurityException] {
        Write-Warning "Unable to set $Path\$Name to $Value due to a Security Exception"
    }
    Catch [System.Management.Automation.ItemNotFoundException] {
        Write-Warning $psitem.Exception.ErrorRecord
    }
    Catch{
        Write-Warning "Unable to set $Name due to unhandled exception"
        Write-Warning $psitem.Exception.StackTrace
    }
}