$chromePath = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
$chromeArguments = '--new-window --incognito'
# if Window not moved (especially on machine start) - try increaing the delay.
$chromeStartDelay = 3

Set-Location $PSScriptRoot
. .\HelperFunctions.ps1

# Kill all running instances
# &taskkill /im chrome* /F

Chrome-Kiosk 'http://www.bbc.com/' -MonitorNum 2
