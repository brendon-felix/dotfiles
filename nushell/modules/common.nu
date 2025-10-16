# ---------------------------------------------------------------------------- #
#                                  common.nu                                   #
# ---------------------------------------------------------------------------- #

export def edit [path?: path] {
    match $path {
        null => (^$env.EDITOR)
        _ => (^$env.EDITOR $path)
    }
}
export alias e = edit

export def show [file: path] {
    let content = open $file -r | highlight
    if ($content | lines | length) > (term size | get rows) {
        $content | less -R
    } else {
        $content
    }
}

export def lg [
    pattern: glob = .   # The glob pattern to use.
    --all (-a)          # Show hidden files
] {
    ls -s --all=$all $pattern | grid -c
}

export def lstr [
    path: path = '.'
    --level(-L): int = 2
] {
    ^lstr $path --level $level --gitignore
}

export def hexdump [file: path] {
    open $file | into binary
}

export def --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}
