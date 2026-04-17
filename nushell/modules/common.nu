# ---------------------------------------------------------------------------- #
#                                  common.nu                                   #
# ---------------------------------------------------------------------------- #

export def e [path?: path] {
    match $path {
        null => (^$env.EDITOR)
        _ => (^$env.EDITOR $path)
    }
}

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

export def r [...args] {
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

export def `describe generic` []: any -> string {
    match $in {
        $v if ($v | describe) == "int" => "number"
        $v if ($v | describe) == "float" => "number"
        _ => ($in | describe | str replace --regex '<.*' '')
    }
}

# # Interpolate between two values based on a parameter `t`, which can be a float (0.0 to 1.0) or an int (0 to 100).
# export def interpolate [
#     end: number,
#     t: number,
# ]: [
#     int -> int
#     float -> float
# ] {
#     let $start = $in
#     if ($end | describe) != ($start | describe) {
#         error make {
#             msg: "type mismatch"
#             label: {
#                 text: "start and end must be of the same type"
#                 span: (metadata $end).span
#             }
#         }
#     }

#     let t = match $t {
#         $t if ($t | describe) == 'int' => {
#             if $t >= 0 and $t <= 100 {
#                 ($t | into float) / 100.0
#             } else {
#                 error make {
#                     msg: "invalid value"
#                     label: {
#                         text: "t must be between 0 and 100"
#                         span: (metadata $t).span
#                     }
#                 }
#             }
#         }
#         $t => {
#             if $t < 0.0 or $t > 1.0 {
#                 error make {
#                     msg: "invalid value"
#                     label: {
#                         text: "t must be between 0.0 and 1.0"
#                         span: (metadata $t).span
#                     }
#                 }
#             }
#             $t
#         }
#     }

#     match $start {
#         $s if ($s | describe) == "int" => ($s + (($end - $s) * $t) | math round)
#         $s if ($s | describe) == "float" => ($s + (($end - $s) * $t))
#     }
# }
