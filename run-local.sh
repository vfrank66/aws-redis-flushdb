# clean a redis database for a full load

## redis-cli FLUSHDB
## redis-cli -n DB_NUMBER FLUSHDB
## redis-cli -n DB_NUMBER FLUSHDB ASYNC
## redis-cli FLUSHALL
## redis-cli FLUSHALL ASYNC
cache_cluster_id=<insert cache cluster>
docker_tag_name=aws-redis-flusher

#aws elasticache describe-cache-clusters --query 'CacheClusters[*].CacheClusterId'

if [[ `aws elasticache describe-cache-clusters --cache-cluster-id $cache_cluster_id`  ]]; then 
    printf "found cache cluster\n"
    address=`aws elasticache describe-cache-clusters \
            --cache-cluster-id $cache_cluster_id \
            --show-cache-node-info      \
            --query "CacheClusters[0].CacheNodes[0].Endpoint.Address"` 
    port=`aws elasticache describe-cache-clusters \
            --cache-cluster-id $cache_cluster_id \
            --show-cache-node-info      \
            --query "CacheClusters[0].CacheNodes[0].Endpoint.Port"`     
    redis_engine_version=`aws elasticache describe-cache-clusters \
            --cache-cluster-id $cache_cluster_id \
            --show-cache-node-info      \
            --query "CacheClusters[0].EngineVersion"` 

    address=`sed -e 's/^"//' -e 's/"$//' <<< ${address}`
    redis_engine_version=`sed -e 's/^"//' -e 's/"$//' <<< ${redis_engine_version}`
    printf "address: $address\n"
    printf "port: $port\n"
    printf "redis version: $redis_engine_version\n"

    docker build --build-arg redis_engine_version=$redis_engine_version \
                --build-arg address=$address \
                --build-arg port=$port \
                . -t $docker_tag_name
    docker run --expose=$port -p 80:80 $docker_tag_name
else 
    printf "did not find cache cluster please review current clusters"
    aws elasticache describe-cache-clusters 
fi 
