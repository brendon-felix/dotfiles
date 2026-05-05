
def "nu-complete arrowhead-files" [] {
    cd ~/Arrowhead
    obsidian files
}

export def `arrowhead file` [
    path: path@"nu-complete arrowhead-files"
] {
    cd ~/Arrowhead
    mut file = obsidian file $"path=($path)" | lines | parse "{field}\t{value}" | str trim | each {|e| {$e.field: $e.value}} | into record
    # mut file = obsidian file $"path=(fzf)" | lines | parse "{field}\t{value}" | str trim | each {|e| {$e.field: $e.value}} | into record
    $file.size = $file.size | into filesize
    $file.created = $file.created | str substring ..9 | into datetime -f %s
    $file.modified = $file.modified | str substring ..9 | into datetime -f %s
    $file
}

export def `arrowhead notebook` [
    path: path@"nu-complete arrowhead-files"
] {
    cd ~/Arrowhead
}

export def `arrowhead notebook new` [] {
    cd ~/Arrowhead
    obsidian
}
