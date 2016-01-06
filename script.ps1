$DebugPreference = "Continue"

# Making sure there are no other instances running
Get-Process powershell | where Id -ne $pid | kill

# Dependencies
Set-Location $PSScriptRoot
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -Path Tomin.Tools.KioskMode.dll
$WinAPI = [Tomin.Tools.KioskMode.WinApi]
$Helpers = [Tomin.Tools.KioskMode.Helper]

function Get-ChromeHandle
{
    Get-Process -Name chrome -ea Ignore | where MainWindowTitle | foreach MainWindowHandle
}

# Build basic form
[xml] $xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        SizeToContent="WidthAndHeight"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanMinimize"
        MinWidth="300"
        Title="Video">
    <Window.Resources>
        <Style TargetType="{x:Type Control}" x:Key="defaultStyle">
            <Setter Property="FontSize" Value="25"/>
            <Setter Property="Margin" Value="2"/>
        </Style>
        <Style TargetType="{x:Type Button}" BasedOn="{StaticResource defaultStyle}" />
    </Window.Resources>
    <StackPanel x:Name="stack">
        <Label x:Name="lblTimer" FontSize="35" HorizontalAlignment="Center" VerticalAlignment="Center"/>
    </StackPanel>
</Window>
'@

$form = [Windows.Markup.XamlReader]::Load( (New-Object Xml.XmlNodeReader $xaml) )
$stack = $form.FindName("stack")
$lblTimer = $form.FindName("lblTimer")

# Reading data
$lists = foreach( $file in ls $PSScriptRoot\Lists\*.csv )
{
    $content = Import-Csv $file.FullName
    if( $content | where seen -ne "True" | select -First 1 )
    {
        [PsCustomObject] @{
            Name = $file.BaseName
            FilePath = $file.FullName
            Content = $content
        }
    }
}

# Setting up timer
$GLOBAL:timerStart = $null
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [timeSpan]::FromSeconds(1)
$timer.add_Tick({
    if( $GLOBAL:timerStart )
    {
        $elapsed = [datetime]::Now - $GLOBAL:timerStart
        $lblTimer.Content = $elapsed.ToString("hh\:mm\:ss")
    }
})
$timer.Start()

# Binding data
foreach( $item in $lists )
{
    $button = New-Object System.Windows.Controls.Button -Property @{
        Name = $item.Name
        Content = $item.Name
    }
    $button.add_Click({
        # Prepare timer
        if( -not $GLOBAL:timerStart )
        {
            $GLOBAL:timerStart = [datetime]::Now
        }

        # Finding corresponding list
        $button = $args[0]
        $list = $lists | where Name -eq $button.Name

        # Getting video to show
        $video = $list.Content | where seen -ne "True" | Get-Random
        $url = "https://www.youtube.com/embed/$($video.VideoId)?autoplay=1"
        $txtDescription.Text = $video.title + "`r`n" + $video.description
        $scroll.Visibility = "Visible"

        # Cleaning up previous crome instance
        # Send Alt+F4 to browser window to exit gracefully
        Get-ChromeHandle | foreach {
            Write-Debug "killing $psitem"
            $Helpers::SendKey($psitem, '%{F4}')
        }

        # Make sure all chrome processes did end
        $killingStarted = [datetime]::now
        while( Get-Process chrome -ea Ignore )
        {
            Write-Debug "waiting for chrome processed to be killed"
            Start-Sleep -Seconds 0.1

            if( ([datetime]::now - $killingStarted) -gt [timespan]::Parse("00:00:01") )
            {
                # Sometimes browser process exists but other chrome processes would not unload.
                # Ignore that situation. Chrome browser window seems to work fine after restart.
                if( -not (Get-ChromeHandle) )
                {
                    Write-Debug "browser process ended but other chrome processes did not, ignoring"
                    break
                }
            }
        }

        # Start new chrome window
        # TODO: Sometimes browser window would not show even after it is called, retry starting
        do
        {
            Write-Debug "trying to start new chrome instance"
            Start-Process 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' "--new-window $url"
            $runStarted = [datetime]::now

            while( -not (Get-ChromeHandle) )
            {
                if( ([datetime]::now - $runStarted) -gt [timespan]::Parse("00:00:05") )
                {
                    break
                }
                Start-Sleep -Seconds 0.1
                Write-Debug "waiting chrome to start"
            }
        }
        until( Get-ChromeHandle )

        # Show video on second monitor
        Get-ChromeHandle | foreach {
            Write-Debug "moving $psitem"
            $WinAPI::ShowWindow($psitem, [Tomin.Tools.KioskMode.Enums.ShowWindowCommands]::Restore)
            $Helpers::MoveToMonitor($psitem, 2)
            Write-Debug "enlarging $psitem"
            $Helpers::SendKey($psitem, '{F11}')
        }

        # Updating video metadata
        $video.seen = $true
        $list.Content | Export-Csv $list.FilePath -NoTypeInformation -Force -Encoding UTF8
        if( -not ($list.Content | where seen -ne "True" | select -First 1) )
        {
            $stack.Children.Remove( $button )
        }
    })
    $stack.Children.Add( $button ) | Out-Null
}

$txtDescription = New-Object System.Windows.Controls.TextBlock -Property @{
    Name = "txtDescription"
    FontSize = "16"
    MaxWidth = "300"
    TextWrapping = "Wrap"
    Margin = "10"
}

$scroll = New-Object System.Windows.Controls.ScrollViewer -Property @{
    MaxHeight = "200"
    Visibility = "Collapsed"
}

$scroll.AddChild( $txtDescription ) | Out-Null
$stack.Children.Add( $scroll ) | Out-Null

# Showing form to the user
$form.ShowDialog() | Out-Null



