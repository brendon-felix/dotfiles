
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

export def timer [duration: duration] {
    countdown $duration
    "Done" | contain -p t | blink | splash green
    # print $"(ansi green)("Done")(erase right)(ansi reset)"
}

