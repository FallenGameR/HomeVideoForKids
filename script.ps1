# Build basic form
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework

[xml] $xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        SizeToContent="WidthAndHeight"
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
        if( -not $GLOBAL:timerStart )
        {
            $GLOBAL:timerStart = [datetime]::Now
        }

        Write-Host "hi!"
        $item.Content | Get-Random
        Write-Host "hi!" ($item.Content | Get-Random)
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



