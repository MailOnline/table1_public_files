REDIS_MASTER=$1

pkgin in redis

# add slave line
if [ "$REDIS_MASTER" ]; then
    echo "This Redis will be a slave of master: $REDIS_MASTER" 
    echo "slaveof $REDIS_MASTER 6379" >> /opt/local/etc/redis.conf
else 
    echo "This Redis will be a master"
fi
sleep 10
svcadm enable redis
