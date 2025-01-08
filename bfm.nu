let dev_loc = 'C:\Users\felixb\BIOS'

def get_config [platform, tree] {
    
    match $platform {
        
        'U60' => {
            let repo_loc = [$dev_loc, 'HpWintersWks'] | path join
            let pltpkg_loc = [$repo_loc, 'HpPlatformPkg'] | path join
            let bld_path = [$pltpkg_loc, 'BLD\Fv'] | path join
            {
                name: "Glacier",
                repo_loc: $repo_loc,
                pltpkg_loc: $pltpkg_loc,
                bld_path: $bld_path,
                bootleg_loc: ([$dev_loc, 'Bootlegs\Winters'] | path join),
            }
        }
        'U61' => {
            let repo_loc = [$dev_loc, 'HpWintersWks'] | path join
            let pltpkg_loc = [$repo_loc, 'HpPlatformPkg'] | path join
            let bld_path = [$pltpkg_loc, 'BLD\Fv'] | path join
            {
                name: "Winters",
                repo_loc: $repo_loc,
                pltpkg_loc: $pltpkg_loc,
                bld_path: $bld_path,
                bootleg_loc: ([$dev_loc, 'Bootlegs\Winters'] | path join),
            }
        }
        'U65' => {
            let repo_loc = [$dev_loc, 'HpAvalancheWks'] | path join
            let pltpkg_loc = [$repo_loc, 'HpPlatformPkg'] | path join
            let bld_path = [$pltpkg_loc, 'BLD\Fv'] | path join
            {
                name: "Avalanche",
                repo_loc: $repo_loc,
                pltpkg_loc: $pltpkg_loc,
                bld_path: $bld_path,
                bootleg_loc: ([$dev_loc, 'Bootlegs\Avalanche'] | path join),
            }
        }
        'X60' | null => {
            let repo_loc = if $tree != null {
                let loc = [$dev_loc, $tree] | path join
                if ($loc | path exists) {
                    $loc
                } else {
                    print $"(ansi red_bold)Specified tree not found!(ansi reset)"
                    exit 1
                }
            } else {
                ([$dev_loc, 'HpSpringsWks'] | path join)
            }
            # print ['C:\Users\felixb\BIOS', $tree]
            # let repo_loc = 'C:\Users\felixb\BIOS\HpSpringsWks'
            let pltpkg_loc = [$repo_loc, 'HpPlatformPkg'] | path join
            let bld_path = [$pltpkg_loc, 'BLD\FV'] | path join
            {
                name: "Springs",
                repo_loc: $repo_loc,
                pltpkg_loc: $pltpkg_loc,
                bld_path: $bld_path,
                bootleg_loc: ([$dev_loc, 'Bootlegs\Springs'] | path join),
            }
        }
        _ => {
            exit 1
        }
    }
}

def build [config, release] {
    # print $"(ansi purple)Building binary...(ansi reset)"
    cd $config.pltpkg_loc
    try {
        # print $release
        if $release {
            print $"(ansi purple)Building RELEASE binary...(ansi reset)"
            match $config.name {
                "Glacier" => {HpBldGlacier.bat r}
                "Winters" => {HpBldBlizzard.bat r}
                "Avalanche" => {HpBiosBuild.bat r}
                "Springs" | null => {HpBldSprings.bat r}
            }
        } else {
            print $"(ansi purple)Building DEBUG binary...(ansi reset)"
            match $config.name {
                "Glacier" => HpBldGlacier.bat
                "Winters" => HpBldBlizzard.bat
                "Avalanche" => HpBiosBuild.bat
                "Springs" | null => HpBldSprings.bat
            }
        }
        
        print print $"\n\n(ansi green)Build successful(ansi reset)"
    } catch {
        print print $"\n\n(ansi red)Build failed(ansi reset)"
        exit 1
    }
    cd -
}

def save [bootleg_loc, binary_path, append?: string] {
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
                ls $path | where name =~ '^(?i)(?!.*pvt).*?(32|64).*\.bin$' | sort-by modified | last
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
    print $"Size: ($binary.size)"
}

def find_build [bld_path] {
    let binary = get_binary $bld_path
    if $binary != null {
        print -n $"Found binary in build folder: "
        print_info $binary
    }
    $binary
}

def find_bootleg [bootleg_loc] {
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
    try {
        do {dpcmd --batch $binary.name --verify}
        print $"\n(ansi green_bold)Flash successful(ansi reset)"
    } catch {
        print $"(ansi red)Flash failed(ansi reset)"
        exit 1
    }
}

def main [
    platform?: string
    --build(-b) # Build the binary
    --release(-r) # Build a release binary
    --bootleg(-l) # Use the latest bootleg binary
    --save(-s) # Save the build to the bootlegs folder
    --flash(-f) # Flash the binary using DediProg
    --tree(-t): string # Specify a specific tree to use
    --path(-p): string # Manually specify a filepath for a binary to flash
    --append(-a): string # Append a string to the bootleg basename
] {
    let config = get_config $platform $tree
    print $"Using config for (ansi blue)($config.name)(ansi reset) with tree ($config.repo_loc | path basename)"
    let binary = if $build {
        build $config $release
        find_build $config.bld_path
    } else if $bootleg {
        find_bootleg $config.bootleg_loc
    } else if $path != null {
        find_path $path
    } else {
        print $"(ansi yellow)No binary provided(ansi reset)"
        find_build $config.bld_path
    }
    if $binary == null {
        print -e $"(ansi red_bold)No binary found(ansi reset)"
        exit 1
    }
    if $save {
        save $config.bootleg_loc $binary.name $append
    }
    if $flash {
        flash $binary
    } else {
        print $"(ansi yellow)Skipped flash(ansi reset)"
    }
}
