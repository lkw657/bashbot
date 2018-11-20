function ircBash {
    if echo "$3" | egrep -qs '^#bash '; then
        local bashee=$(echo "$3" | cut -d ' ' -f2)
        ircAction "$2" "bashes $bashee upside the head"
    fi
}

ircAddPrivMod ircBash
