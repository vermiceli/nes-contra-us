@echo off

rem Assembles and links the source assemblies into a .nes ROM.
rem Run this script from the windows command prompt.
rem If desired, there is also a build.ps1 powershell script
rem that can be used as well.

IF EXIST contra.nes (
    echo Deleting contra.nes.
    del contra.nes
)

IF NOT EXIST "obj" (
    mkdir "obj"
)

IF EXIST "obj\*.o" (
   echo Deleting object files.
   del "obj\*.o"
)

IF NOT EXIST baserom.nes (
    echo No baserom.nes file found.  If assets are missing, then the build will fail.
)

rem show commands run in output
echo Assembling PRG Rom Banks

rem loop through assets defined in assets.txt and extract bytes from baserom.nes
echo Extracting binary data from baserom.nes
for /f "tokens=1,2,3 delims= " %%i in (assets.txt) do (
  cscript /nologo set_bytes.vbs %%j %%k %%i
)

@echo on
ca65 -g --debug-info -o obj\constants.o src\constants.asm
ca65 -g --debug-info -o obj\ines_header.o src\ines_header.asm
ca65 -g --debug-info -o obj\bank0.o src\bank0.asm
ca65 -g --debug-info -o obj\bank1.o src\bank1.asm
ca65 -g --debug-info -o obj\bank2.o src\bank2.asm
ca65 -g --debug-info -o obj\bank3.o src\bank3.asm
ca65 -g --debug-info -o obj\bank4.o src\bank4.asm
ca65 -g --debug-info -o obj\bank5.o src\bank5.asm
ca65 -g --debug-info -o obj\bank6.o src\bank6.asm
ca65 -g --debug-info -o obj\bank7.o src\bank7.asm
@echo off

rem link assemblies together to single .nes ROM

echo "Creating .nes ROM"

@echo on
ld65 -C contra.cfg --dbgfile contra.dbg .\obj\constants.o .\obj\ines_header.o .\obj\bank0.o .\obj\bank1.o .\obj\bank2.o .\obj\bank3.o .\obj\bank4.o .\obj\bank5.o .\obj\bank6.o .\obj\bank7.o -o contra.nes
@echo off