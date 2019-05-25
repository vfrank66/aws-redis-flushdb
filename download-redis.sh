wget http://download.redis.io/releases/redis-5.0.0.tar.gz
tar xzf redis-5.0.0.tar.gz
cd redis-5.0.0
make
cd src

./redis-cli -h <redis cache cluster> \
-p 6379 --scan | grep mykeyword | xargs  ./redis-cli \
-h <redis cache cluster> -p 6379 DEL