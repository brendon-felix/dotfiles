# This script is used to import new Super I/O firmware
# 
# Usage:
#   siofw [path]
# 

def get_file [path] {
    mut file = ""
    if (ls $path | length) == 1 {
        print -n $"Found specified binary: "
        $file = (ls $path).0
        print_info $file
    }
    $file
}

def print_info [file] {
    print $"(ansi blue)($file.name | path basename)(ansi reset)"
    print $"Size: ($file.size)\n"
}

def main [path: string] {
    let file = (get_file $path)
    cp $file.name C:\Users\felixb\BIOS\HpSpringsWks\HpEpsc\HpNuvoton324Pkg\Include\HpSioDev\HpSuperIoFw.bin
}
