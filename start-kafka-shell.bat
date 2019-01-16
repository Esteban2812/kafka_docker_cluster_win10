docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -e HOST_IP=%1 -e ZK=%2 -i -t --network="kafka-docker-master_default" wurstmeister/kafka /bin/bash
