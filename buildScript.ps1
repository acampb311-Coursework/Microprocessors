$step=$args[0]
.\CASM12Z.EXE $step L S
Start-Sleep -s 0.25
[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
[Microsoft.VisualBasic.Interaction]::AppActivate("CASM12Z")
[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
