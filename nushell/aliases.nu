alias r = nu ./run.nu
alias du = dust
alias vim = nvim
alias ln = coreutils ln

alias m = nu --config ~/Projects/dotfiles/nushell/ext-config.nu -e 'print banner'

alias spew = spewcap2.exe

# alias chat = rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/chat_prompt.txt
# alias gpt = rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/gpt_prompt.txt
alias hey = rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/chat_prompt.txt
# alias teach = rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/teach_prompt.txt
# alias `what is` = rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/chat_prompt.txt 'What is '
# alias `what are` = rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/chat_prompt.txt 'What are '
# alias chef = rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/chef_prompt.txt
alias askvim = rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/askvim_prompt.txt
# alias eg = rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/eg_prompt.txt

alias gsw = git switch
alias gbr = git branch
alias grh = git reset --hard
alias gcl = git clean -fd

def grst [] {
    git reset --hard
    git clean -fd
}

def gpsh [] {
    git add .
    git commit -m "quick update"
    git push
}

alias b2sum = coreutils b2sum
alias b3sum = coreutils b3sum
alias base32 = coreutils base32
alias base64 = coreutils base64
alias basename = coreutils basename
alias basenc = coreutils basenc
alias cat = coreutils cat
alias cksum = coreutils cksum
alias comm = coreutils comm
alias csplit = coreutils csplit
alias cut = coreutils cut
alias dd = coreutils dd
alias df = coreutils df
alias dir = coreutils dir
alias dircolors = coreutils dircolors
alias dirname = coreutils dirname
alias env = coreutils env
alias expr = coreutils expr
alias factor = coreutils factor
alias fmt = coreutils fmt
alias fold = coreutils fold
alias hashsum = coreutils hashsum
alias head = coreutils head
alias md5sum = coreutils md5sum
alias nl = coreutils nl
alias numfmt = coreutils numfmt
alias od = coreutils od
alias paste = coreutils paste
alias pr = coreutils pr
alias printenv = coreutils printenv
alias printf = coreutils printf
alias ptx = coreutils ptx
alias readlink = coreutils readlink
alias realpath = coreutils realpath
alias rmdir = coreutils rmdir
alias sha1sum = coreutils sha1sum
alias sha224sum = coreutils sha224sum
alias sha256sum = coreutils sha256sum
alias sha3-224sum = coreutils sha3-224sum
alias sha3-256sum = coreutils sha3-256sum
alias sha3-384sum = coreutils sha3-384sum
alias sha3-512sum = coreutils sha3-512sum
alias sha384sum = coreutils sha384sum
alias sha3sum = coreutils sha3sum
alias sha512sum = coreutils sha512sum
alias shake128sum = coreutils shake128sum
alias shake256sum = coreutils shake256sum
alias shred = coreutils shred
alias shuf = coreutils shuf
alias sum = coreutils sum
alias tac = coreutils tac
alias tail = coreutils tail
alias tr = coreutils tr
alias truncate = coreutils truncate
alias tsort = coreutils tsort
alias unexpand = coreutils unexpand
alias unlink = coreutils unlink
alias vdir = coreutils vdir
alias wc = coreutils wc
alias yes = coreutils yes
