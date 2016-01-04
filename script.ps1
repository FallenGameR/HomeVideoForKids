Add-Type –assemblyName WindowsBase
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName PresentationFramework

[xml]$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="UAT" Height="300" Width="300">
    <Grid>
        <Button Name="btnGo" Content="Go" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="207,240,0,0"/>
        <TextBox Name="txtOut" HorizontalAlignment="Left" Height="233" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="272" Margin="10,0,0,0"/>
    </Grid>
</Window>
'@

$reader=(New-Object Xml.XmlNodeReader $xaml)
$MainForm=[Windows.Markup.XamlReader]::Load( $reader )

$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $MainForm.FindName($_.Name) -Scope Global}

$btnGo.add_Click({
    $txtOut.text = ""
    $uri = new-object system.uri("f:\OneDrive\Ero\Ольга Кобзар\2arTNISKdQw.jpg")
    $imagesource = new-object System.Windows.Media.Imaging.BitmapImage $uri
    $imagebrush = new-object System.Windows.Media.ImageBrush  $imagesource
    $txtOut.background = $imagebrush
})

$MainForm.ShowDialog() | out-null




<#
<Window x:Class="WpfApplication1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication1"
        mc:Ignorable="d"
        SizeToContent="WidthAndHeight"
        Title="MainWindow">
    <Window.Resources>
        <Style TargetType="{x:Type Control}" x:Key="defaultStyle">
            <Setter Property="FontSize" Value="22"/>
            <Setter Property="Margin" Value="2"/>
        </Style>
        <Style TargetType="{x:Type Button}" BasedOn="{StaticResource defaultStyle}" />
    </Window.Resources>
    <StackPanel x:Name="stack">
        <Label x:Name="lblTimer" FontSize="30" HorizontalAlignment="Center" VerticalAlignment="Center"/>
        <Button>
            test
        </Button>
    </StackPanel>
</Window>



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

        public MainWindow()
        {
            InitializeComponent();

            DispatcherTimer timer = new DispatcherTimer();
            timer.Interval = TimeSpan.FromSeconds(0.1);
            timer.Tick += Timer_Tick;

            timerStart = DateTime.Now;
            timer.Start();

            stack.Children.Add(new Button { Content = "test me" });
            stack.Children.Add(new Button { Content = "Галилео" });
        }

        private void Timer_Tick(object sender, EventArgs e)
        {
            var elapsed = DateTime.Now - timerStart;
            lblTimer.Content = elapsed.ToString(@"hh\:mm\:ss");
        }
    }
}

#>
