docker-machine create -d virtualbox mesos-1
docker-machine create -d virtualbox mesos-2
docker-machine create -d virtualbox mesos-3
docker-machine ssh mesos-1 'sudo sed -i "\$a127.0.0.1 mesos-1" /etc/hosts'
docker-machine ssh mesos-1 'sudo sed -i "\$a127.0.0.1 mesos-2" /etc/hosts'
docker-machine ssh mesos-3 'sudo sed -i "\$a127.0.0.1 mesos-3" /etc/hosts'
 eval $(docker-machine env mesos-1)
 MESOS1=$(docker-machine ip mesos-1)
 MESOS2=$(docker-machine ip mesos-2)
 MESOS3=$(docker-machine ip mesos-3)
 docker run --name master -d --net=host -e MESOS_ZK=zk://$MESOS1:2181/mesos -e MESOS_IP=$MESOS1 -e MESOS_HOSTNAME=$MESOS1  -e MESOS_QUORUM=1 mesosphere/mesos-master:0.28.1 
 docker run --name agent -d --net=host -e MESOS_MASTER=zk://$MESOS1:2181/mesos -e MESOS_CONTAINERIZERS=docker  -e MESOS_IP=$MESOS1 -e MESOS_HOSTNAME=$MESOS1 -e MESOS_EXECUTOR_REGISTRATION_TIMEOUT=10mins            -e MESOS_RESOURCES="ports(*):[80-32000]"              -e MESOS_HOSTNAME=$MESOS1  -v /var/run/docker.sock:/run/docker.sock -v /usr/local/bin/docker:/usr/bin/docker -v /sys:/sys:ro mesosphere/mesos-slave:0.28.1
 docker run -d --name marathon -p 9000:8080   mesosphere/marathon:v1.1.1 --master zk://$MESOS1:2181/mesos    --zk zk://$MESOS1:2181/marathon  --task_launch_timeout 600000
 eval $(docker-machine env mesos-2)
 docker run --name agent -d --net=host \
             -e MESOS_MASTER=zk://$MESOS1:2181/mesos \
             -e MESOS_CONTAINERIZERS=docker \
             -e MESOS_IP=$MESOS2 \
             -e MESOS_HOSTNAME=$MESOS2 \
             -e MESOS_EXECUTOR_REGISTRATION_TIMEOUT=10mins \
             -e MESOS_RESOURCES="ports(*):[80-32000]" \
             -v /var/run/docker.sock:/run/docker.sock \
             -v /usr/local/bin/docker:/usr/bin/docker \
             -v /sys:/sys:ro \
             mesosphere/mesos-slave:0.28.1
eval $(docker-machine env mesos-3)
docker run --name agent -d --net=host \
             -e MESOS_MASTER=zk://$MESOS1:2181/mesos \
             -e MESOS_CONTAINERIZERS=docker \
             -e MESOS_IP=$MESOS3 \
             -e MESOS_HOSTNAME=$MESOS3 \
             -e MESOS_EXECUTOR_REGISTRATION_TIMEOUT=10mins \
             -e MESOS_RESOURCES="ports(*):[80-32000]" \
             -v /var/run/docker.sock:/run/docker.sock \
             -v /usr/local/bin/docker:/usr/bin/docker \
             -v /sys:/sys:ro \
             mesosphere/mesos-slave:0.28.1             