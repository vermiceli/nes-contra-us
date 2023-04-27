#!/bin/bash

# Assembles and links the source assemblies into a .nes ROM.

# Run this script from a bash terminal if on linux or mac.
# If you are on windows, use either build.ps1, or build.bat

us_contra_hash=1c747c78c678f14a68d4e5fcae065298a103f833638775860f0e5c5ffaa061f62d45fd8942148b1507c1fd57fde950a5d83f9f84a9782ec048a56067740c48e9

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

if test -f "contra.nes"
then
    echo "Deleting contra.nes."
    rm contra.nes
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
    ROM_HASH=$(sha512sum baserom.nes | awk '{print $1}')
    if [[ "$ROM_HASH" != $us_contra_hash ]]
    then
        echo "baserom.nes file integrity does NOT match expected result."
    fi
fi

# loop through assets defined in assets.txt and extract bytes from baserom.nes
echo "Extracting binary data from baserom.nes"
while read -r line || [ -n "$p" ]
do
    set $line
    file=$1
    start=$2
    length=$3
    length=$(echo $length | tr -d '\r')
    setBytes $start $length $file
done < assets.txt

echo "Assembling PRG Rom Banks"
ca65 -g --debug-info -o obj/constants.o src/constants.asm
ca65 -g --debug-info -o obj/ines_header.o src/ines_header.asm
ca65 -g --debug-info -o obj/bank0.o src/bank0.asm
ca65 -g --debug-info -o obj/bank1.o src/bank1.asm
ca65 -g --debug-info -o obj/bank2.o src/bank2.asm
ca65 -g --debug-info -o obj/bank3.o src/bank3.asm
ca65 -g --debug-info -o obj/bank4.o src/bank4.asm
ca65 -g --debug-info -o obj/bank5.o src/bank5.asm
ca65 -g --debug-info -o obj/bank6.o src/bank6.asm
ca65 -g --debug-info -o obj/bank7.o src/bank7.asm

echo "Creating .nes ROM"
ld65 -C contra.cfg --dbgfile contra.dbg ./obj/constants.o ./obj/ines_header.o ./obj/bank0.o ./obj/bank1.o ./obj/bank2.o ./obj/bank3.o ./obj/bank4.o ./obj/bank5.o ./obj/bank6.o ./obj/bank7.o -o contra.nes

if test -f "contra.nes"
then
    # compare assembled ROM hash to expected hash
    ROM_HASH=$(sha512sum contra.nes | awk '{print $1}')
    if [[ "$ROM_HASH" == $us_contra_hash ]]
    then
        echo "File integrity matches."
    else
        echo "File integrity does NOT match."
    fi
fi