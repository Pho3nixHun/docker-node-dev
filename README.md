    docker context create <alias> --docker "host=ssh://<remote-docker-machine>"
    docker run --name node-dev -d -v app:/usr/src/app docker-node-dev
