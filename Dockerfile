FROM ubuntu

RUN apt-get update \ 
    && apt-get install -y bc

RUN useradd bashbot

WORKDIR /bashbot

COPY . .

VOLUME /bashbot/modules

RUN chmod +x bashbot.sh

USER bashbot

ENTRYPOINT ["/bashbot/bashbot.sh"]
