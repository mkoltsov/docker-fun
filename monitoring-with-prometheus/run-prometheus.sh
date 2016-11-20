docker run -d --name prometheus -p 9090:9090 \
             -v $PWD/prometheus.conf:/prometheus.conf \
             --link cadvisor:cadvisor \
             prom/prometheus -config.file=/prometheus.conf
