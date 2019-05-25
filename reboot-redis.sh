# this will reboot the cache cluster
cache_cluster_id=<insert cache cluster>

aws elasticache reboot-cache-cluster \
            --cache-cluster-id $cache_cluster_id