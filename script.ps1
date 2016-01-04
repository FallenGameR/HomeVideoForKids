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





