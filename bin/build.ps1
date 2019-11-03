# By Default github action windows env does not set up build tools, call VsDevCmd build tools
# Setup visual studio build tools
& "${env:COMSPEC}" /s /c "`"C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\Tools\VsDevCmd.bat`" -no_logo && set" | foreach-object {
    $name, $value = $_ -split '=', 2
    set-content env:\"$name" $value
}
# Test nmake
nmake -help
bison --help
flex --help

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Invoke-WebRequest -UseBasicParsing -OutFile rubyc.zip -Uri http://enclose.io/rubyc/rubyc-x64.zip
Unzip "rubyc.zip" "rubyc"
.\rubyc\rubyc-v0.4.0-x64.exe --clean-tmpdir -o build\metanorma bin\metanorma
# Check build folder
dir "C:/Users/RUNNER~1/AppData/Local/Temp/rubyc/zlib"