Add-Type –AssemblyName WindowsBase
Add-Type –AssemblyName PresentationCore
Add-Type –AssemblyName PresentationFramework

[xml]$xaml = @'
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
        <Button x:Name="btnGo">
            test
        </Button>
    </StackPanel>
</Window>
'@

$form = [Windows.Markup.XamlReader]::Load( (New-Object Xml.XmlNodeReader $xaml) )
$xaml.SelectNodes("//*[@Name]") | foreach{ Set-Variable -Name $psitem.Name -Value $form.FindName($psitem.Name) -Scope Global }



$stack.Children.Add( New-Object System.Windows.Controls.Button -Property @{ Content = "test me" } )
$stack.Children.Add( New-Object System.Windows.Controls.Button -Property @{ Content = "Галилео" } )




$btnGo.add_Click({
    $txtOut.text = ""
    $uri = new-object system.uri("f:\OneDrive\Ero\Ольга Кобзар\2arTNISKdQw.jpg")
    $imagesource = new-object System.Windows.Media.Imaging.BitmapImage $uri
    $imagebrush = new-object System.Windows.Media.ImageBrush  $imagesource
    $txtOut.background = $imagebrush
})

$form.ShowDialog() | Out-Null




<#



using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Threading;

namespace WpfApplication1
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        DateTime timerStart;

             [System.Windows.Threading.DispatcherTimer] timer = new DispatcherTimer();
            timer.Interval = TimeSpan.FromSeconds(0.1);
            timer.Tick += Timer_Tick;

            timerStart = DateTime.Now;
            timer.Start();

        }

        private void Timer_Tick(object sender, EventArgs e)
        {
            var elapsed = DateTime.Now - timerStart;
            lblTimer.Content = elapsed.ToString(@"hh\:mm\:ss");
        }
    }
}

#>
