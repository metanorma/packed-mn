# By Default github action windows env does not set up build tools, call VsDevCmd build tools
# Setup visual studio build tools
& "${env:COMSPEC}" /s /c "`"C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\Tools\VsDevCmd.bat`" -no_logo && set" | foreach-object {
    $name, $value = $_ -split '=', 2
    set-content env:\"$name" $value
}
git clone https://github.com/sass/libsass.git
cd .\libsass
MSBuild.exe win\libsass.sln `
/p:LIBSASS_STATIC_LIB=1 /p:Configuration=Release
cd ..
# Test nmake
nmake -help
# Copy alias for bison and flex
$win_bison = where.exe win_bison
cp $win_bison $win_bison.Replace('win_bison', 'bison')
$win_flex = where.exe win_flex
cp $win_flex $win_flex.Replace('win_flex', 'flex')
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
SET LIBSASS_STATIC_LIB=1
.\rubyc\rubyc-v0.4.0-x64.exe --clean-tmpdir -o build\metanorma bin\metanorma