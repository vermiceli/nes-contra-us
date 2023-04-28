# Assembles and links the source assemblies into a .nes ROM.
# Run this script from powershell if available, if not available use build.bat
# batch file from the windows command prompt.

$global:SOURCE_CONTRA = $null
$US_CONTRA_HASH = "1C747C78C678F14A68D4E5FCAE065298A103F833638775860F0E5C5FFAA061F62D45FD8942148B1507C1FD57FDE950A5D83F9F84A9782EC048A56067740C48E9"

<#
.SYNOPSIS

Copies bytes from the Contra US NES rom file into binary files for use when
assembling.
#>
function Set-Bytes {
    param ($Skip, $Take, $Output)

    IF (Test-Path -Path $Output) {
        return
    }

    # only read baserom.nes once for speed improvements
    IF ($global:SOURCE_CONTRA -eq $null) {
        Write-Output "    Reading input file baserom.nes."
        IF ($PSVersionTable.PSVersion.Major -ge 6) {
            $global:SOURCE_CONTRA = Get-Content .\baserom.nes -AsByteStream
        } ELSE {
            $global:SOURCE_CONTRA = Get-Content .\baserom.nes -Raw -Encoding Byte
        }
    }

    Write-Output "    Writing file $Output."
    
    IF ($PSVersionTable.PSVersion.Major -ge 6) {
        $global:SOURCE_CONTRA | Select-Object -Skip $Skip -First $Take | Set-Content $Output -AsByteStream
    } ELSE {
        $global:SOURCE_CONTRA | Select-Object -Skip $Skip -First $Take | Set-Content $Output -Encoding Byte
    }
}

IF (Test-Path -Path "contra.nes") {
    Write-Output "Deleting contra.nes."
    Remove-Item -Path "contra.nes"
}

IF (-not (Test-Path -Path "obj")) {
    New-Item -ItemType Directory -Path obj
}

IF (Test-Path -Path obj\*.o) {
    Write-Output "Deleting object files."
    Remove-Item -Path obj\*.o
}

IF (-not (Test-Path -Path "baserom.nes")) {
    Write-Output "No baserom.nes file found.  If assets are missing, then the build will fail."
} ELSE {
    $SHA512_HASH = (Get-FileHash baserom.nes -Algorithm SHA512).Hash
    IF ($SHA512_HASH -ne $US_CONTRA_HASH) {
        Write-Warning "baserom.nes file integrity does NOT match expected result."
    }
}

# loop through assets defined in assets.txt and extract bytes from baserom.nes
Write-Output "Extracting binary data from baserom.nes"
ForEach ($line in Get-Content -Path assets.txt) {
    $tokens = -split $line
    Set-Bytes -Skip $tokens[1] -Take $tokens[2] -Output $tokens[0]
}

# prevent write race condition
Start-Sleep -Milliseconds 100

Write-Output "Assembling PRG Rom Banks"

# show commands run in output
Set-PSDebug -Trace 1
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

Set-PSDebug -Trace 0

# link assemblies together to single .nes ROM
Write-Output "Creating .nes ROM"

Set-PSDebug -Trace 1
ld65 -C contra.cfg --dbgfile contra.dbg .\obj\constants.o .\obj\ines_header.o .\obj\bank0.o .\obj\bank1.o .\obj\bank2.o .\obj\bank3.o .\obj\bank4.o .\obj\bank5.o .\obj\bank6.o .\obj\bank7.o -o contra.nes

# compare assembled ROM hash to expected hash if file exists
Set-PSDebug -Trace 0
IF (Test-Path -Path "contra.nes") {
    $SHA512_HASH = (Get-FileHash contra.nes -Algorithm SHA512).Hash

    IF ($SHA512_HASH -eq $US_CONTRA_HASH) {
        Write-Output "File integrity matches."
    } ELSE {
        Write-Warning "File integrity does NOT match."
    }
}
