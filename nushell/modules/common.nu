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

export def r [
    ...args
] {
    if not ('run.nu' | path exists) {
        error make -u {msg: "run.nu not found in the current directory"}
    }
    nu run.nu ...$args
}

# Run a closure n times, passing the current index to the closure
export def do-n [
    n: int
    closure: closure
] {
    if $n < 1 {
        error make {
            msg: "invalid value of n"
            label: "n must be greater than zero"
        }
    }
    for i in 1..$n {
        do $closure $i
    }
}
