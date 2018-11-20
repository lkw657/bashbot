#!/bin/bash

if [ -z $1 ] || [ -z $2 ]; then
    echo "Usage: ./bashbot.sh [server] [channels]"
    echo "Example: ./bashbot.sh 'irc.server.com/6667' '#foo #bar'"
    exit
fi

server=$1
channels=$2
nick="bashbot"

echo "server: $server"
echo "channels: $channels"

exec 3<>/dev/tcp/$server
echo "connected"

function ircQuote {
    echo -e "$1" >&3
}

# responds to a PING message
function ircPing {
    if echo "$1" | egrep -qs "^PING "; then
        local resp=$(echo "$1" | cut -d ' ' -f2)
        ircQuote "PONG $resp"
    fi
}

function ircPrivmsg {
    ircQuote "PRIVMSG $1 :$2"
}

#like ircPrivmsg but for /me
function ircAction {
    ircQuote "$(echo -e "PRIVMSG $1 :\x01ACTION $2\x01")"
}

function ircQuit {
    ircQuote "QUIT :$1"
}

# quit nicely when recieving ctrl-c
trap ircIntHandler INT
function ircIntHandler {
    ircQuit "bye"
    # close socket
    exec 3<&-
    exit
}

# functions to run when any message is received from the server
mods=("ircPing" "ircHandlePrivmsg" "echo")
# function to run when PRIVMSG is received
privMods=()

function ircAddMod {
    mods+=("$1")
}

function ircAddPrivMod {
    privMods+=("$1")
}

# there isn't really any proper (un)loading yet, just reset the lists
function unloadMods {
    mods=("ircPing" "ircHandlePrivmsg" "echo")
    privMods=()
}

# runs functions in privMods when a PRIVMSG is received
function ircHandlePrivmsg {
    if echo $1 | egrep -qs "^\S* PRIVMSG "; then
        local user=$(echo "${1}" | cut -d ' ' -f1 | sed 's/^:\(.*\)$/\1/g')
        local source=$(echo "${1}" | cut -d ' ' -f3)
        local message=$(echo "${1}" | cut -d ' ' -f4- | sed 's/^:\(.*\)$/\1/g' | tr -d '\r\n')
        for mod in "${privMods[@]}"; do
            $mod "$user" "$source" "$message"
        done
    fi
}

# last time something in ./modules was modified
moduleModificationTime=0

# returns the latest modification time in ./modules
function getModificationTime {
    echo $(stat -c %Y modules/* | sort -nr | head -n 1)
}

# reloads modules if a file has been modified since the last check
function ircHotload {
    newModified=$(getModificationTime)
    if (( moduleModificationTime == 0 || newModified > moduleModificationTime )); then
        unloadMods
        echo "reloading modules"
        for file in $(ls modules); do
            source "modules/$file"
        done
        moduleModificationTime=$(getModificationTime)
        ircAddMod ircHotload
        echo "modules: ${mods[@]}"
        echo "priv modules: ${privMods[@]}"
    fi
}


ircAddMod ircHotload

ircQuote "NICK $nick"
ircQuote "USER $nick $nick $nick :$nick"
#server pings to confirm registration
read -u 3 line
ircPing "$line"
ircQuote "MODE $nick +B"

for channel in $channels; do
    echo "joining $channel"
    ircQuote "JOIN $channel"
done

while true; do
    read -u 3 line
    for mod in "${mods[@]}"; do
        $mod "$line"
    done
done
