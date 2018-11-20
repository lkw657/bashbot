function ircEcho {
    if echo "$3" | egrep -qs '^#echo '; then
        local user=$(echo "$1" | cut -d '!' -f1)
        local message=$(echo "$3" | cut -d ' ' -f2-)
        ircPrivmsg "$2" "$user: $message"
    fi
}

ircAddPrivMod ircEcho
