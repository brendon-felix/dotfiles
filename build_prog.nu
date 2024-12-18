
# cd 

# cd 'C:\Program Files (x86)\DediProg\SF Programmer'
# dpcmd --detect
# dpcmd --type MX25L25673G --batch ($nu.home-path | path join 'BIOS\Bootlegs\Avalanche\U65_890121_32.bin') --verify

# (ls *.bin | sort-by modified | last).name

# def main [file_path?: string] {
#     if $file_path == null {
#         echo "no file name"
#     } else {
#         echo $file_path
#     }
# }

dpcmd --detect