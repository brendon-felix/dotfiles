# This script is used to import new Super I/O firmware
# 
# Usage:
#   siofw [path]
# 

# def get_file [path] {
#     mut file = ""
#     if (ls $path | length) == 1 {
#         print -n $"Found specified binary: "
#         $file = (ls $path).0
#         print_info $file
#     }
#     $file
# }

# def print_info [file] {
#     print $"(ansi blue)($file.name | path basename)(ansi reset)"
#     print $"Size: ($file.size)\n"
# }

# def main [path: string] {
#     let file = (get_file $path)
#     cp $file.name C:\Users\felixb\BIOS\HpSpringsWks\HpEpsc\HpNuvoton324Pkg\Include\HpSioDev\HpSuperIoFw.bin
# }


# /* -------------------------------------------------------------------------- */

# def main [version] {
#     mut file = open test.equ
#     print ($file | str replace -r '[a-fA-F0-9]{7}h' $'($version)h')
# }

# /* -------------------------------------------------------------------------- */

def get_ver [file] {
    let val = $file | parse -r '(?P<version>[a-fA-F0-9]{7})h' | first | get version
    $val | parse -r '0(?P<maj>[a-fA-F0-9]{2})(?P<min>[a-fA-F0-9]{2})(?P<feat>[a-fA-F0-9]{2})' | first
        | each { |it| $it | str trim -c '0' } | values | str join '.'
    # $val | parse -r '0(?P<maj>[a-fA-F0-9]{2}){3}'
}

def make_equ_str [version] {
    let v = $version | split row '.'
        | each { |it| $it | fill -a r -c '0' -w 2 } | str join
    ['0', $v] | str join
}

def update_equ [filepath, version] {
    mut equ_file = open $filepath
    let equ_str = make_equ_str $version
    let curr_ver = get_ver $equ_file
    print $"Changing from (ansi grey)v($curr_ver)(ansi reset) to (ansi yellow)v($version)(ansi reset)"
    # ($equ_file | str replace -r '[a-fA-F0-9]{7}h' $'($equ_str)h') | save -f $filepath
    print $"(ansi green)Successfully updated(ansi reset) ($filepath | path basename)"
}

def main [version] {
    let equ_filename = 'C:\Users\felixb\BIOS\HpSpringsWks\HpEpsc\HpNuvoton324Pkg\Include\HpSioFireBirdFwVersion.equ'
    
    let new_bin = try {
        (ls ($'~\Downloads\*($version)*' | into glob) | sort-by modified | last)
    } catch {
        print $"(ansi red)Could not find binary file matching ($version)(ansi reset)"
        exit 1
    }
    print $"Found binary (ansi blue)($new_bin.name | path basename)(ansi reset)"
    update_equ $equ_filename $version
    
    print $"Copying new binary to HpEpsc..."
    try {
        # cp $new_bin.name ./HpEpsc/HpNuvoton324Pkg/Include/HpSioDev/HpSuperIoFw.bin
    } catch {
        print $"(ansi red)Failed copying(ansi reset) ($new_bin.name | path basename)"
        exit 1
    }
    print $"(ansi green)Successfully copied(ansi reset) ($new_bin.name | path basename) to HpEpsc"
    # 
    # cp (ls ($'~/Downloads/*($version)*.bin' | into glob) | sort-by modified | last).name HpSuperIoFw.bin
}