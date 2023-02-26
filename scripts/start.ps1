Start-Transcript $ENV:TEMP\Winutil.log -Append

#Load DLLs
Add-Type -AssemblyName System.Windows.Forms

# variable to sync between runspaces
$sync = [Hashtable]::Synchronized(@{})
$sync.IsDev = $true
$sync.PSScriptRoot = $PSScriptRoot
$sync.configs = @{}