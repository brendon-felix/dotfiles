# This script is used to build, save, and flash a binary for the HP Springs platform.
# 
# Usage:
#   bfm [options]
# 
# Options:
#   --build, -b    Build the binary. If no binary is found, the latest bootleg is used.
#   --save, -s     Save the binary to the bootlegs folder. Requires the --build flag.
#   --flash, -f    Flash the binary using DediProg.
# 
# Description:
#   The script first checks if the --build flag is provided. If so, it builds the binary
#   using the HpBldSprings.bat script located in the HpPlatformPkg directory. If the build
#   is successful, it saves the binary to the bootlegs folder if the --save flag is also
#   provided. If the --build flag is not provided, it uses the latest bootleg binary found
#   in the bootlegs folder.
# 
#   If the --flash flag is provided, the script flashes the binary using the DediProg
#   command-line tool.
# 
# Example:
#   To build, save, and flash the binary:
#     bfm --build --save --flash
# 
#   To use the latest bootleg binary and flash it:
#     bfm --flash

def main [
    --build(-b) # Build the binary
    --bootleg(-l) # Use the latest bootleg binary
    --save(-s) # Save the build to the bootlegs folder
    --flash(-f) # Flash the binary using DediProg
    --path(-p): string # Manually specify a filepath for a binary to flash
] {
    mut binary = ""
    if $build {
        print "Building binary..."
        cd 'C:\Users\felixb\BIOS\HpSpringsWks\HpPlatformPkg\' 
        HpBldSprings.bat
        if (ls C:\Users\felixb\BIOS\HpSpringsWks\HpPlatformPkg\BLD\FV\*_64.bin | length) > 0 {
            $binary = (ls C:\Users\felixb\BIOS\HpSpringsWks\HpPlatformPkg\BLD\FV\*_64.bin | first)
            print $"(ansi green_bold)Successfully built binary '($binary | path basename)'!(ansi reset)"
            print $"Using build: '($binary.name | path basename)'..."
            if $save {
                print $"Saving binary '($binary.name | path basename)' to bootlegs folder..."
                cp $binary.name C:\Users\felixb\BIOS\Bootlegs\Springs\
            }
        } else {
            print -e $"(ansi red)No matching binary found in build folder!(ansi reset)"
            exit 1
        }
    } else {
        if $save {
            print -e $"(ansi red)'--save'/'-s' flag requires '--build'/'-b' flag!(ansi reset)"
            exit 1
        }
        if $path != "" {
            $binary = (ls $path).0
            print $"Using specified binary: '($binary.name | path basename)'..."
        } else if $bootleg {
            if (ls C:\Users\felixb\BIOS\Bootlegs\Springs\*_64.bin | length) > 0 {
                $binary = (ls C:\Users\felixb\BIOS\Bootlegs\Springs\*_64.bin | sort-by modified | last)
                print $"Using latest bootleg '($binary.name | path basename)'..."
            }
            else {
                print -e $"(ansi red)No matching binary found in bootlegs folder!(ansi reset)"
                exit 1
            }
        } else if (ls C:\Users\felixb\BIOS\HpSpringsWks\HpPlatformPkg\BLD\FV\*_64.bin | length) > 0 {
            print $"Using existing build: '($binary.name | path basename)'..."
            $binary = (ls C:\Users\felixb\BIOS\HpSpringsWks\HpPlatformPkg\BLD\FV\*_64.bin | first)
        } else {
            print -e $"(ansi red)No matching binary found!(ansi reset)"
            exit 1
        }
    }
    if $flash {
        print $"Flashing binary '($binary.name | path basename)'..."
        print $"Size: ($binary.size) bytes\n"
        # dpcmd --detect | ignore
        dpcmd --batch $binary.name --verify
        print $"\n(ansi green_bold)Successfully flashed!(ansi reset)"
    }
    # print $binary
}
