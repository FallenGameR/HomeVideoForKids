$DebugPreference = "Continue"

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

function Get-ChromeHandle( [switch] $wait )
{
    Write-Debug "peaking"
    $window = Get-Process -Name chrome -ea Ignore | where MainWindowTitle

    if( $wait )
    {
        while( -not $window )
        {
            Start-Sleep -Seconds 0.1
            $window = Get-Process -Name chrome -ea Ignore | where MainWindowTitle
            Write-Debug "searching"
        }
    }

    if( $window )
    {
        $window.MainWindowHandle
    }
}

# Build basic form
[xml] $xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        SizeToContent="WidthAndHeight"
        WindowStartupLocation="CenterScreen"
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
    [PsCustomObject] @{
        Name = $file.BaseName
        FilePath = $file.FullName
        Content = Import-Csv $file.FullName
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
        $list = $lists | where Name -eq $args[0].Name

        # Getting video to show
        $video = $list.Content | where seen -ne "True" | Get-Random
        $url = "https://www.youtube.com/embed/$($video.VideoId)?autoplay=1"
        $txtDescription.Text = $video.title + "`r`n" + $video.description
        $txtDescription.Visibility = "Visible"

        # Cleaning up
        Get-ChromeHandle | foreach {
            Write-Debug "killing $psitem"
            $Helpers::SendKey($psitem, '%{F4}')
            while( Get-Process chrome -ea Ignore )
            {
                Write-Debug "waiting for kill $psitem"
                Start-Sleep -Seconds 0.1
            }
        }

        # Show video on second monitor
        Write-Debug "starting"
        Start-Process 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' "--new-window $url"
        Get-ChromeHandle -Wait | foreach {
            Write-Debug "moving $psitem"
            $WinAPI::ShowWindow($psitem, [Tomin.Tools.KioskMode.Enums.ShowWindowCommands]::Restore)
            $Helpers::MoveToMonitor($psitem, 2)
            Write-Debug "enlarging $psitem"
            $Helpers::SendKey($psitem, '{F11}')
        }

        # Updating video metadata
        $video.seen = $true
        $list.Content | Export-Csv $list.FilePath -NoTypeInformation -Force -Encoding UTF8
    })
    $stack.Children.Add( $button ) | Out-Null
}

$txtDescription = New-Object System.Windows.Controls.TextBlock -Property @{
    Name = "txtDescription"
    FontSize = "16"
    MaxWidth = "300"
    TextWrapping = "Wrap"
    Margin = "10"
    Visibility = "Collapsed"
}
$stack.Children.Add( $txtDescription ) | Out-Null

# Showing form to the user
$form.ShowDialog() | Out-Null



