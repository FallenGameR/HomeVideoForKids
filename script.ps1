# Build basic form
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework

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

# Manually bind with data
$lists = foreach( $file in ls $PSScriptRoot\Lists\*.csv )
{
    [PsCustomObject] @{
        Name = $file.BaseName
        FilePath = $file.FullName
        Content = Import-Csv $file.FullName
    }
}
$GLOBAL:timerStart = $null

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

        # Cleaning up
        #Get-Process chrome -ea Ignore | kill

        # Prepare Chrome
        $chromePath = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
        $chromeArguments = '--new-window'
        $chromeStartDelay = 3 # if window not moved (especially on machine start) - try increaing the delay
        Set-Location $PSScriptRoot
        . .\HelperFunctions.ps1

        # Get URL to show
        $video = $item.Content | Get-Random
        $url = "https://www.youtube.com/embed/$($video.VideoId)?autoplay=1"

        # Show video on second monitor
        Chrome-Kiosk $url -MonitorNum 2
    })
    $stack.Children.Add( $button ) | Out-Null
}

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

$form.ShowDialog() | Out-Null



