$filename=$args[0]
.\CASM12Z.EXE $filename L S
Start-Sleep -s 0.25
[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
[Microsoft.VisualBasic.Interaction]::AppActivate("CASM12Z")
[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
$s19File = [io.path]::GetFileNameWithoutExtension($filename) + ".s19"
Get-Content $s19File


$header = 'LOAD'
$file   = $s19File

$header | Set-Content tempfile.txt
Get-Content $file -ReadCount 5000 |
Add-Content tempfile.txt
Get-Content tempfile.txt  | Set-Clipboard
Remove-item $file
Rename-Item tempfile.txt -NewName $file

[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
[Microsoft.VisualBasic.Interaction]::AppActivate("Atom")
[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")


#Add-Content "LOAD" -Value (Get-Content $s19File)
$errorFile = [io.path]::GetFileNameWithoutExtension($filename) + ".ERR"
Get-Content $errorFile
