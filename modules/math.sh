function ircMath {
    if echo "$3" | egrep -qs '^#math '; then
        local eqn=$(echo "$3" | cut -d ' ' -f2-)
        local res=$(echo "$eqn" | timeout -k 1.5s 1s bc -l 2>&1 | tr -d '\r\n')
        ircPrivmsg "$2" "$res"
    fi
}

ircAddPrivMod ircMath
