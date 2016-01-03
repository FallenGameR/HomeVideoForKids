$wshell = new-object -com wscript.shell
while( $true )
{
    Get-Process | where{ $_.MainWindowTitle.StartsWith("Un") } | foreach{
        $wshell.AppActivate($_.MainWindowTitle)
        $wshell.SendKeys("Y`n")
    }
    Start-Sleep -s 10
}



Win+Shift+Right
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait('~'); # on active app
