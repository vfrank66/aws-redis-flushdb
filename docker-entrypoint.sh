set -x
printf "starting stunnell..\n"
stunnel /etc/stunnel/redis-cli.conf

printf "stunnel conf:\n"
cat /etc/stunnel/redis-cli.conf
printf "\n"
printf "stunnel pid running=\n"
cat /var/run/stunnel.pid

#netstat -plunt
printf "confirming the tunnels have started\n"
netstat -tulnp | grep -i stunnel

printf "running redis-cli flush all ..\n"
redis-cli -h localhost -p $REDIS_PORT FLUSHALL
#printf 'flush all complete'