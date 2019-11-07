git clone https://github.com/sass/libsass.git
cd .\libsass
MSBuild.exe win\libsass.sln `
/p:LIBSASS_STATIC_LIB=1 /p:Configuration=Release