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



def build [] {
    print "Building binary..."
    cd 'C:\Users\felixb\BIOS\HpWintersWks\HpPlatformPkg\' 
    HpBldBlizzard.bat
    cd ~
}

def save [binary] {
    print $"Saving new build (ansi blue)($binary.name | path basename)(ansi reset) to bootlegs folder..."
    cp $binary.name C:\Users\felixb\BIOS\Bootlegs\Winters\
}

def find_build [] {
    mut binary = ""
    if (ls C:\Users\felixb\BIOS\HpWintersWks\HpPlatformPkg\BLD\Fv\*_32.bin | length) > 0 {
        print -n $"Found binary in build folder: "
        $binary = (ls C:\Users\felixb\BIOS\HpWintersWks\HpPlatformPkg\BLD\Fv\*_32.bin | first)
        print_info $binary
    }
    $binary
}

def find_bootleg [] {
    mut binary = ""
    if (ls C:\Users\felixb\BIOS\Bootlegs\Winters\*_32.bin | length) > 0 {
        print -n $"Found binary in bootlegs folder: "
        $binary = (ls C:\Users\felixb\BIOS\Bootlegs\Winters\*_32.bin | sort-by modified | last)
        print_info $binary
    }
    $binary
}

def find_path [path] {
    mut binary = ""
    if (ls $path | length) > 0 {
        print -n $"Found specified binary: "
        $binary = (ls $path).0
        print_info $binary
    }
    $binary
}

def print_info [binary] {
    print $"(ansi blue)($binary.name | path basename)(ansi reset)"
    print $"Size: ($binary.size)\n"
}

def flash [binary] {
    print $"Flashing binary..."
    
    do {dpcmd --batch $binary.name --verify}
    if $env.LAST_EXIT_CODE == 0 {
        print $"\n\n(ansi green_bold)!! Successfully flashed !!(ansi reset)"
    } else {
        print $"\n\n(ansi red)!! Failed to flash !!(ansi reset)"
    }
}

def main [
    --build(-b) # Build the binary
    --bootleg(-l) # Use the latest bootleg binary
    --save(-s) # Save the build to the bootlegs folder
    --flash(-f) # Flash the binary using DediProg
    --path(-p): string = "" # Manually specify a filepath for a binary to flash
] {
    mut binary = ""
    if $build {
        build
        $binary = (find_build)
        if $save {
            save $binary
        }
    } else if $bootleg {
        $binary = (find_bootleg)
    } else if $path != "" {
        $binary = (find_path $path)
    } else {
        print "No binary provided, using existing build..."
        $binary = (find_build)
        if $binary == "" {
            print -e $"(ansi red)No binary found!(ansi reset)"
            exit 1
        }
    }
    if $flash {
        flash $binary
    } else {
        print $"(ansi yellow)Skipped flashing!(ansi reset)"
    }
}
