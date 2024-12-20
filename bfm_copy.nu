let repo_loc = 'C:\Users\felixb\BIOS\HpSpringsWks'
# let repo_loc = 'C:\Users\felixb\BIOS\HpSpringsA'
# let repo_loc = 'C:\Users\felixb\BIOS\HpAvalancheWks'
# let repo_loc = 'C:\Users\felixb\BIOS\HpWintersWks'

let bootleg_loc = 'C:\Users\felixb\BIOS\Bootlegs\Springs'
# let bootleg_loc = 'C:\Users\felixb\BIOS\Bootlegs\Avalanche'
# let bootleg_loc = 'C:\Users\felixb\BIOS\Bootlegs\Winters'

let plt_pkg = [$repo_loc, 'HpPlatformPkg'] | path join

def build [] {
    print $"(ansi purple)Building binary...(ansi reset)"
    cd $plt_pkg
    HpBldSprings.bat
    cd ~
}

def save [binary_path, append?: string] {
    let bootleg_basename = match $append {
        null => ($binary_path | path basename)
        _ => {
            let parsed = $binary_path | path parse
            $parsed.stem + '_' + $append + '.' + $parsed.extension
        }
    }
    let bootleg_path = [$bootleg_loc, $bootleg_basename] | path join
    cp $binary_path $bootleg_path
    print $"Saved bootleg (ansi blue)($bootleg_basename)(ansi reset)"
}

def get_binary [path] {
    try {
        match ($path | path type) {
            'dir' => {
                let pattern = [$path, '*_*_*.bin'] | path join
                ls ($pattern | into glob) | sort-by modified | last
            }
            'file' => (ls $path | sort-by modified | last)
            _ => null
        }
    } catch {
        null
    }
}

def print_info [binary] {
    print $"(ansi blue)($binary.name | path basename)(ansi reset)"
    print $"Size: ($binary.size)\n"
}

def find_build [] {
    let binary = get_binary ([$plt_pkg, 'BLD\FV'] | path join)
    if $binary != null {
        print -n $"Found binary in build folder: "
        print_info $binary
    }
    $binary
}

def find_bootleg [] {
    let binary = get_binary $bootleg_loc
    if $binary != null {
        print -n $"Found binary in bootlegs folder: "
        print_info $binary
    }
    $binary
}

def find_path [path] {
    let binary = get_binary $path
    if $binary != null {
        print -n $"Found specified binary: "
        print_info $binary
    }
    $binary
}

def flash [binary] {
    print $"(ansi purple)Flashing binary...(ansi reset)"
    do {dpcmd --batch $binary.name --verify}
    if $env.LAST_EXIT_CODE == 0 {
        print $"\n\n!! (ansi green_bold)Successfully flashed(ansi reset) !!"
    } else {
        print $"\n\n!! (ansi red)Failed to flash(ansi reset) !!"
    }
}

def main [
    --build(-b) # Build the binary
    --bootleg(-l) # Use the latest bootleg binary
    --save(-s) # Save the build to the bootlegs folder
    --flash(-f) # Flash the binary using DediProg
    --path(-p): string # Manually specify a filepath for a binary to flash
    --append(-a): string # Append a string to the bootleg basename
] {
    let binary = if $build {
        build
        find_build
    } else if $bootleg {
        find_bootleg
    } else if $path != null {
        find_path $path
    } else {
        print $"(ansi yellow)No binary provided(ansi reset)\nChecking for existing build..."
        find_build
    }
    if $binary == null {
        print -e $"(ansi red_bold)No binary found(ansi reset)"
        exit 1
    }
    if $save {
        save $binary.name $append
    }
    if $flash {
        flash $binary
    } else {
        print $"(ansi yellow)Skipped flash(ansi reset)"
    }
}
