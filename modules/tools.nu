# ---------------------------------------------------------------------------- #
#                                   tools.nu                                   #
# ---------------------------------------------------------------------------- #

use print-utils.nu countdown
use splash.nu *

# Send a request to Wolfram Alpha and print the response
export def wa [...input: string] {
    let APPID = open ~/wolfram_appid.txt | str trim
    let question_string = $input | str join ' ' | url encode
    let url = (["https://api.wolframalpha.com/v1/result?appid=", $APPID, "&i=", $question_string] | str join)
    curl $url
}

export alias du = dust
export alias vim = nvim

export alias spewcap = ~/Projects/spewcap2/target/release/spewcap2.exe
export alias size = ~/Projects/size-converter/target/release/size-converter.exe

# General purpose chat assistant
export alias chat = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/gpt_prompt.txt

# General purpose chat assistant
export alias gpt = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/gpt_prompt.txt

# Chat assistant for general teaching
export alias teach = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/teach_prompt.txt

# Ask for recipes by providing ingredients and preferences
export alias chef = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/chef_prompt.txt

# Ask about Vim, Neovim, and vi motions.
export alias askvim = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/askvim_prompt.txt

# alias calc = ~/Projects/qalculate/qalc.exe -c
export alias qalc = ~/Projects/qalculate/qalc.exe -c
export alias calc = ~/kalc.exe
export alias kalc = ~/kalc.exe

export alias mix = ~/Projects/mix/target/release/mix.exe

export def timer [duration: duration] {
    countdown $duration
    "Done" | contain -p t | blink | splash green
    

    # print $"(ansi green)("Done")(erase right)(ansi reset)"
}