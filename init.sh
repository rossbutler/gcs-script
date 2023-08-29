#!/bin/sh

docker_config='{
    "data-root":"'$HOME'/.docker/data",
    "log-driver":"json-file",
    "log-opts":{
        "max-size":"100m",
        "max-file":"3"
        }
}'

init_docker() {
    if [ ! -f ~/.docker/data ];then
        mkdir -p ~/.docker/data
    fi;
    if [ ! -f /etc/docker/daemon.json ];then
        echo $docker_config |sudo tee /etc/docker/daemon.json
        sudo /etc/init.d/docker restart
        # docker run -d --name pause --restart always alpine sleep infinity
    fi;
    while [ "$(/etc/init.d/docker status|grep running)" = "" ];do
        echo "wait docker up"
        sleep 1s
    done
    if [ ! -e /usr/local/bin/docker-compose ];then
        sudo wget -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-linux-x86_64 2>/dev/null 
    fi
}
init_docker
if [ -n "$COMPOSE_URL" ];then
sudo wget -O /tmp/default-srv-compose.yaml $COMPOSE_URL
docker-compose -p default-srv -f /tmp/default-srv-compose.yaml up -d --remove-orphans
fi
