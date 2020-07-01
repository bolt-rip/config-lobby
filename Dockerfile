FROM alpine:3.12 AS BUILD

RUN mkdir /minecraft

WORKDIR /minecraft

COPY . .

RUN mkdir -p ~/.ssh
COPY id_rsa_map_lobby /root/.ssh/id_rsa_map_lobby
RUN chmod og-rwx ~/.ssh/id_rsa_map_lobby

RUN apk upgrade --no-cache \
    && apk add --no-cache git openssh-client curl

RUN GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_map_lobby" \
    git clone --depth=1 --branch=master git@github.com:bolt-rip/map-lobby.git world
RUN rm -rf ./world/.git

RUN curl https://pkg.ashcon.app/sportpaper -Lo sportpaper.jar

FROM adoptopenjdk/openjdk8-openj9:alpine-slim

RUN addgroup -g 1000 minecraft && \
    adduser -u 1000 -D -G minecraft minecraft

RUN mkdir /minecraft
RUN chown minecraft:minecraft -R /minecraft
WORKDIR /minecraft
COPY --from=BUILD --chown=minecraft:minecraft /minecraft .

USER minecraft
ENTRYPOINT [ "/minecraft/run.sh" ]