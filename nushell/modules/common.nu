
export def show [file: path] {
    let content = open $file -r | highlight
    if ($content | lines | length) > (term size | get rows) * 2 {
        $content | less -R
    } else {
        $content
    }
}

export def lg [
    pattern: glob = .   # The glob pattern to use.
    --all (-a)          # Show hidden files
] {
    ls -s --all=$all ...$pattern | grid -c
}

export def lstr [
    path: path = '.'
    --level(-L): int = 2
] {
    ^lstr $path --level $level --gitignore
}
