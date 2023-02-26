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
