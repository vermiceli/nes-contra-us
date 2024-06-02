@echo off

rem Assembles and links the source assemblies into a .nes ROM.
rem Run this script from the windows command prompt if you do not have access to
rem PowerShell.  This script does not do some hashing validation that PowerShell
rem can.

SET ROM_NAME="contra.nes"
SET DBG_NAME="contra.dbg"
SET ASSETS_NAME=assets.txt
SET ASSET_GAME_TYPE=src\assets\asset-game-type.txt
SET GAME="%1"

IF %GAME% == "Probotector" (
    SET ROM_NAME="probotector.nes"
    SET DBG_NAME="probotector.dbg"
    SET ASSETS_NAME=probotector-assets.txt
) ELSE (
    SET GAME="Contra"
)

IF EXIST %ROM_NAME% (
    echo Deleting %ROM_NAME%.
    del %ROM_NAME%
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

rem used to know which assets were last build
SET LAST_BUILD_TYPE="Contra"
IF EXIST %ASSET_GAME_TYPE% (
    SET /p LAST_BUILD_TYPE=<%ASSET_GAME_TYPE%
)

rem If the assets are from a different game, then delete them
rem For example, if the assets were extracted from Contra and currently building
rem Probotector, then delete the assets and extract them from the Probotector baserom.nes
IF NOT %LAST_BUILD_TYPE% == %Game% (
    echo Removing graphic asset files
    del src\assets\graphic_data\*.bin
)

rem loop through assets defined in assets.txt (or probotector-assets.txt) and extract bytes from baserom.nes
echo Extracting binary data from baserom.nes
for /f "tokens=1,2,3 delims= " %%i in (%ASSETS_NAME%) do (
  cscript /nologo set_bytes.vbs %%j %%k %%i
)

rem Store game type that the assets are for
IF EXIST %ASSET_GAME_TYPE% (
    del %ASSET_GAME_TYPE%
)

echo %GAME%>%ASSET_GAME_TYPE%

rem show commands run in output
echo Assembling PRG Rom Banks

@echo on
ca65 -D %GAME% --debug-info -o obj\ram.o src\ram.asm
ca65 -D %GAME% --debug-info -o obj\constants.o src\constants.asm
ca65 -D %GAME% --debug-info -o obj\ines_header.o src\ines_header.asm
ca65 -D %GAME% --debug-info -o obj\bank0.o src\bank0.asm
ca65 -D %GAME% --debug-info -o obj\bank1.o src\bank1.asm
ca65 -D %GAME% --debug-info -o obj\bank2.o src\bank2.asm
ca65 -D %GAME% --debug-info -o obj\bank3.o src\bank3.asm
ca65 -D %GAME% --debug-info -o obj\bank4.o src\bank4.asm
ca65 -D %GAME% --debug-info -o obj\bank5.o src\bank5.asm
ca65 -D %GAME% --debug-info -o obj\bank6.o src\bank6.asm
ca65 -D %GAME% --debug-info -o obj\bank7.o src\bank7.asm
@echo off

rem link assemblies together to single .nes ROM

echo "Creating .nes ROM"

@echo on
ld65 -C contra.cfg --dbgfile %DBG_NAME% .\obj\ram.o .\obj\constants.o .\obj\ines_header.o .\obj\bank0.o .\obj\bank1.o .\obj\bank2.o .\obj\bank3.o .\obj\bank4.o .\obj\bank5.o .\obj\bank6.o .\obj\bank7.o -o %ROM_NAME%
@echo off