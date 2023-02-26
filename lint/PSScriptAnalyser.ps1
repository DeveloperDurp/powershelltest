function SuppressWriteHost()
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
    param()

    Write-Verbose -Message "Ignoring Write-Host"

}