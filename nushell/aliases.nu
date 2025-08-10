alias r = nu ./run.nu
alias du = dust
alias vim = nvim

def tree [--level(-L): int = 2] {
    tree.exe -C -L $level --dirsfirst --noreport -H
}

# alias calc = ~/Projects/qalculate/qalc.exe -c
alias qalc = ~/Projects/qalculate/qalc.exe -c
alias calc = ~/kalc.exe
alias kalc = ~/kalc.exe

alias mix = ~/Projects/mix/target/release/mix.exe

alias m = nu --config ~/Projects/dotfiles/nushell/ext-config.nu -e 'print banner'

alias spewcap = ~/Projects/spewcap2/target/release/spewcap2.exe
alias size = ~/Projects/size-converter/target/release/size-converter.exe

alias chat = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/chat_prompt.txt
alias `show me` = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/chat_prompt.txt 'Show me '
alias gpt = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/gpt_prompt.txt
alias hey = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/gpt_prompt.txt
alias teach = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/teach_prompt.txt
alias `what is` = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/chat_prompt.txt 'What is '
alias `what are` = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/chat_prompt.txt 'What are '
alias chef = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/chef_prompt.txt
alias askvim = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/askvim_prompt.txt
alias eg = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -p ~/Arrowhead/Files/Prompts/eg_prompt.txt

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
