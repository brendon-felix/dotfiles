



# def find_path [path] {
#     mut binary = ""
#     if (ls $path | length) > 0 {
#         print -n $"Found specified binary: "
#         $binary = (ls $path).0
#         print_info $binary
#     }
#     $binary
# }


def main [
    --dir(-d): string = ""
    --ver(-v): string = ""
] {
    let pattern = $"($dir)*($ver)*"
    print $pattern
    let files = ls $pattern
    print $files
    # mut binary = ""
    # if $path != "" {
    #     $binary = (find_path $path)
    # } else {
    #     print -e $"(ansi red)No binary found!(ansi reset)"
    #     exit 1
    # }
    # cp $binary.name ~\BIOS\HpSpringsWks\HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSuperIoFw.bin

}