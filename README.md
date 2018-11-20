# Bashbot
An irc bot written in bash for the lulz

### Features
* Fairly easy to extend
* Hot (re)loading of modules

### Todo
* ssl
* Nicer module system that handles loading, unloading and dependancies properly
* Make it understand users and modes
* Make it easier to respond to events other than PRIVMSG

### How duz I run?
```
./bashbot.sh irc.serverhere.com '#channel1 #channel2'
```
With docker
```
docker build -t bashbot
docker run -d -it bashbot irc.serverhere.com '#channel1 #channel2'
```
For hot (re)loading
```
docker build -t bashbot .
docker run -d -it \
    -v $(pwd)/modules:/bashbot/modules \
    bashbot \
    irc.serverhere.com '#channel1 #channel2'
```
