# mut parsed = ('~/test.txt' | path parse)
# print $parsed
# $parsed.stem = $parsed.stem + '_append'
# $parsed.parent = ''
# print $parsed
# let basename = ($parsed | path join)
# print ($'path/($basename)')



# def main [
#     --path(-p): string
#     # --append(-a): string = "" # Append a string to the bootleg basename
# ] {
#     if $path != null {
#         print $path
#     } else {
#         print "No path given!"
#     }
# }


# let repo_loc = 'C:\Users\felixb\BIOS\HpSpringsWks'
# let plt_pkg = [$repo_loc, 'HpPlatformPkg'] | path join
# print $plt_pkg


# let len = (ls C:\Users\felixb\BIOS\HpSpringsWks\HpPlatformPkg\BLD\FV\*_32.bin | length) | default null

def get_binary [path] {
    try {
        let type = ($path | path type)
        match $type {
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

get_binary C:\Users\felixb\BIOS\Bootlegs\Springs\X60_830020_64_D4_14_5.bin
# get_binary 'C:\Users\felixb\BIOS\Bootlegs\Springs\*.bin'
# get_binary '~'

# let file = get_binary C:\Users\felixb\BIOS\HpSpringsWks\HpPlatformPkg\BLD\FV
# if $file == null {
#     print "couldn't get file"
# } else {
#     print $"got file ($file.name | path basename)"
# }