
# ---------------------------------------------------------------------------- #
#                                   tools.nu                                   #
# ---------------------------------------------------------------------------- #

# Send a request to Wolfram Alpha and print the response
export def wa [...input: string] {
    let APPID = open ~/wolfram_appid.txt | str trim
    let question_string = $input | str join ' ' | url encode
    let url = (["https://api.wolframalpha.com/v1/result?appid=", $APPID, "&i=", $question_string] | str join)
    curl $url
}

export alias spew = spewcap2

export alias hey = hey -p ~/Arrowhead/Files/Prompts/gpt_prompt.txt
export alias askvim = hey -p ~/Arrowhead/Files/Prompts/askvim_prompt.txt
export alias eg = hey -p ~/Arrowhead/Files/Prompts/eg_prompt.txt

export alias jupyter = /opt/homebrew/opt/jupyterlab/bin/jupyter-lab
