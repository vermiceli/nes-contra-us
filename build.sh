#!/bin/bash

# Assembles and links the source assemblies into a .nes ROM.

# Run this script from a bash terminal if on linux or mac.
# If you are on windows, use either build.ps1, or build.bat
GAME="$1"
GAME_HASH="1c747c78c678f14a68d4e5fcae065298a103f833638775860f0e5c5ffaa061f62d45fd8942148b1507c1fd57fde950a5d83f9f84a9782ec048a56067740c48e9"
ROM_NAME="contra.nes"
DBG_NAME="contra.dbg"
ASSETS_NAME="assets.txt"
ASSET_GAME_TYPE="src/assets/asset-game-type.txt"

if [[ "$GAME" == "Probotector" ]]
then
    ROM_NAME="probotector.nes"
    DBG_NAME="probotector.dbg"
    GAME_HASH="a4bda4572ec8a3f520deb4bf483510f6e41ed7665505850d22ec07ca1b25abff40b3368a27ece982ea6e9c71a1b698eb2add16c26a7ad67dba3c0a98c4e2ba43"
    ASSETS_NAME="probotector-assets.txt"
else
    GAME="Contra"
fi

# function to check between different available hash functions
# mac doesn't come with sha512sum by default, but includes shasum
romHasher() {
    if command -v sha512sum &> /dev/null
    then
        sha512sum $1
    else
        shasum -a 512 $1
    fi
}

setBytes(){
    if test -f $3
    then
        return
    fi

    echo "    Writing file $3."
    dd bs=1 skip=$1 count=$2 if=baserom.nes of=$3 status=none
}

if ! ld65 --version &> /dev/null
then
    echo "cc65 compiler suite could not be found. Please install cc65 and add it to your path."
    exit
fi

mkdir -p obj

if test -f ROM_NAME
then
    echo "Deleting ${ROM_NAME}."
    rm ROM_NAME
fi

if test -f "obj/*.o"
then
    echo "Deleting object files."
    rm obj/*.o
fi

if ! test -f "baserom.nes"
then
    echo "No baserom.nes file found.  If assets are missing, then the build will fail."
else
    ROM_HASH=$(romHasher baserom.nes | awk '{print $1}')
    if [[ "$ROM_HASH" != "$GAME_HASH" ]]
    then
        echo "baserom.nes file integrity does NOT match expected result."
    fi
fi

# used to know which assets were last build
LAST_BUILD_TYPE="Contra"
if test -f $ASSET_GAME_TYPE
then
    LAST_BUILD_TYPE=`cat $ASSET_GAME_TYPE`
fi

# If the assets are from a different game, then delete them
# For example, if the assets were extracted from Contra and currently building
# Probotector, then delete the assets and extract them from the Probotector baserom.nes
if [[ "$LAST_BUILD_TYPE" != "$GAME" ]]
then
    echo "Removing graphic asset files"
    rm src/assets/graphic_data/*.bin
fi

# loop through assets defined in assets.txt (or probotector-assets.txt) and extract bytes from baserom.nes
echo "Extracting binary data from baserom.nes"
while read -r line || [ -n "$p" ]
do
    set $line
    file=$1
    start=$2
    length=$3
    length=$(echo $length | tr -d '\r')
    file=$(echo "$file" | tr '\\' '/')
    setBytes $start $length $file
done < $ASSETS_NAME

echo "$GAME" > $ASSET_GAME_TYPE

echo "Assembling PRG Rom Banks"
ca65 -D $GAME --debug-info -o obj/ram.o src/ram.asm
ca65 -D $GAME --debug-info -o obj/constants.o src/constants.asm
ca65 -D $GAME --debug-info -o obj/ines_header.o src/ines_header.asm
ca65 -D $GAME --debug-info -o obj/bank0.o src/bank0.asm
ca65 -D $GAME --debug-info -o obj/bank1.o src/bank1.asm
ca65 -D $GAME --debug-info -o obj/bank2.o src/bank2.asm
ca65 -D $GAME --debug-info -o obj/bank3.o src/bank3.asm
ca65 -D $GAME --debug-info -o obj/bank4.o src/bank4.asm
ca65 -D $GAME --debug-info -o obj/bank5.o src/bank5.asm
ca65 -D $GAME --debug-info -o obj/bank6.o src/bank6.asm
ca65 -D $GAME --debug-info -o obj/bank7.o src/bank7.asm

echo "Creating .nes ROM"
ld65 -C contra.cfg --dbgfile $DBG_NAME ./obj/ram.o ./obj/constants.o ./obj/ines_header.o ./obj/bank0.o ./obj/bank1.o ./obj/bank2.o ./obj/bank3.o ./obj/bank4.o ./obj/bank5.o ./obj/bank6.o ./obj/bank7.o -o $ROM_NAME

if test -f $ROM_NAME
then
    # compare assembled ROM hash to expected hash
    ROM_HASH=$(romHasher $ROM_NAME | awk '{print $1}')
    if [[ "$ROM_HASH" == "$GAME_HASH" ]]
    then
        echo "File integrity matches."
    else
        echo "File integrity does NOT match."
    fi
fi