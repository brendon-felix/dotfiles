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

export alias chat = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/api_key.txt -p ~/system_prompt.txt
export alias gpt = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/api_key.txt -p ~/system_prompt.txt
export alias teach = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/api_key.txt -p ~/teach_prompt.txt
export alias chef = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/api_key.txt -p ~/chef_prompt.txt

# This is a test
export alias askvim = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/api_key.txt -p ~/askvim_prompt.txt

# alias calc = ~/Projects/qalculate/qalc.exe -c
export alias qalc = ~/Projects/qalculate/qalc.exe -c
export alias calc = ~/kalc.exe
export alias kalc = ~/kalc.exe

export def timer [duration: duration] {
    countdown $duration
    "Done" | contain -p t | blink | splash green
    

    # print $"(ansi green)("Done")(erase right)(ansi reset)"
}