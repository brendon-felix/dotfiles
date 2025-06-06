# ---------------------------------------------------------------------------- #
#                                    git.nu                                    #
# ---------------------------------------------------------------------------- #

export alias gsw = git switch
export alias gbr = git branch
export alias grh = git reset --hard
export alias gcl = git clean -fd

export def grst [] {
    git reset --hard
    git clean -fd
}

export def gpsh [] {
    git add .
    git commit -m "quick update"
    git push
}