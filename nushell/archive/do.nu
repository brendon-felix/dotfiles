
# ---------------------------------------------------------------------------- #
#                                     do.nu                                    #
# ---------------------------------------------------------------------------- #

export def `do thing` [] {
    let i = (((date now | format date "%f" | into int) mod 1000000) / 100) + 1
    print -n $"doing ('thing' | color cycle $i) for ($i)ms..."
    erase right
    print ""
    countup ($i * 1ms)
}

export def `do things` [] {
    loop {
        do thing
    }
}

