$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$targetDir = (Get-Item -Path "$scriptDir/build/html").FullName
$destinationDir = "$scriptDir/.."

$cssDir = "$destinationDir/css"
if( -not (Test-Path -Path $cssDir) )
{
    New-Item -Path $cssDir -ItemType Container
}

function Get-XhtmlContent()
{
    param(
        [string]$Path
        )
    $settings = New-Object System.Xml.XmlReaderSettings;
    $settings.DtdProcessing = [System.Xml.DtdProcessing]::Parse;
    $settings.XmlResolver = New-Object System.Xml.Resolvers.XmlPreloadedResolver -ArgumentList @([System.Xml.Resolvers.XmlKnownDtds]::Xhtml10);
    $stream = New-Object System.IO.FileStream -ArgumentList($Path, [System.IO.FileMode]::Open)
    $reader = [System.Xml.XmlReader]::Create($stream, $settings);
    $xml = New-Object System.Xml.XmlDocument;
    $xml.Load($reader);
    $reader.Dispose();
    $stream.Dispose();
    return $xml
}
function Replace-Images($node)
{
    if( $node.Name -eq "img" )
    {
        $node.src = $node.src.Replace("_images", "images")
    }
    foreach($childNode in $node.ChildNodes)
    {
        Replace-Images $childNode
    }
}
$htmlFiles = Get-ChildItem -Path $targetDir -Filter *.html -Recurse
foreach( $file in $htmlFiles )
{
    $xml = Get-XhtmlContent -Path $file.FullName
    $relativePath = $file.FullName.Replace($targetDir, ".")
    $relativeDir = $file.DirectoryName.Replace($targetDir, ".")
    $depth = $relativeDir.Split('\').Count - 1
    $prefix = [System.String]::Concat([System.Linq.Enumerable]::Repeat("../", $depth))
    foreach($link in $xml.html.head.link)
    {
        if( $link.rel -eq "stylesheet" )
        {
            # Replace href to refer the file under css directory.
            $cssPath = (Join-Path $file.DirectoryName $link.href)
            $cssName = Split-Path -Path $cssPath -Leaf
            $link.href = "${prefix}css/$cssName"
        }
    }
    Replace-Images $xml.html
    $xml.Save("$destinationDir/$relativePath")
}
$stylesheets = Get-ChildItem -Path "$targetDir/_static" -Filter *.css
$stylesheets | Copy-Item -Destination $cssDir

Rename-Item -Path "$destinationDir/_images" -NewName "images"
