function ircShrug {
    if echo "$3" | egrep -qs '^#shrug'; then
        ircPrivmsg "$2" "¯\_(ツ)_/¯"
    fi
}

ircAddPrivMod ircShrug
