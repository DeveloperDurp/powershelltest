$OFS = "`r`n"

Remove-Item .\winutil.ps1

Get-Content .\scripts\start.ps1 | Out-File ./winutil.ps1 -Append

Get-ChildItem .\functions | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./winutil.ps1 -Append
}

Get-ChildItem .\xaml | ForEach-Object {
    $xaml = (Get-Content $psitem.FullName).replace("'","''")
    
    Write-output "`$$($psitem.BaseName) = '$xaml'" | Out-File ./winutil.ps1 -Append
}

Get-ChildItem .\configs | Where-Object {$psitem.extension -eq ".json"} | ForEach-Object {
    $json = (Get-Content $psitem.FullName).replace("'","''")
    
    Write-output "`$sync.configs.$($psitem.BaseName) = '$json' `| convertfrom-json" | Out-File ./winutil.ps1 -Append
}

Get-Content .\scripts\main.ps1 | Out-File ./winutil.ps1 -Append