# ---------------------------------------------------------------------------- #
#                                   tools.nu                                   #
# ---------------------------------------------------------------------------- #

# Send a request to Wolfram Alpha and print the response
export def wa [...input: string] {
    let APPID = open ~/wolfram_appid.txt | str trim
    let question_string = $input | str join ' ' | url encode
    # debug $question_string
    let url = (["https://api.wolframalpha.com/v1/result?appid=", $APPID, "&i=", $question_string] | str join)
    curl $url
}

export alias du = dust
export alias vim = nvim

export alias spewcap = ~/Projects/spewcap2/target/release/spewcap2.exe
export alias size = ~/Projects/size-converter/target/release/size-converter.exe
export alias chat = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/api_key.txt -p ~/system_prompt.txt

# alias calc = ~/Projects/qalculate/qalc.exe -c
alias qalc = ~/Projects/qalculate/qalc.exe -c
alias calc = ~/kalc.exe
alias kalc = ~/kalc.exe