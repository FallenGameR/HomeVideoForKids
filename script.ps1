Add-Type –AssemblyName WindowsBase
Add-Type –AssemblyName PresentationCore
Add-Type –AssemblyName PresentationFramework

[xml] $xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        SizeToContent="WidthAndHeight"
        MinWidth="300"
        Title="Видео">
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

$stack.Children.Add( (New-Object System.Windows.Controls.Button -Property @{ Content = "test me" }) )
$stack.Children.Add( (New-Object System.Windows.Controls.Button -Property @{ Content = "Галилео" }) )


$timerStart = Get-Date

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [timeSpan]::FromSeconds(0.1)
$timer.add_Tick({
    $elapsed = (Get-Date) - $timerStart
    $lblTimer.Content = "{0:hh\:mm\:ss}" -f $elapsed
})
$timer.Start()


$form.ShowDialog() | Out-Null



