#prepends a timestamp in seconds since EPOCH
docker run -it --rm --link MyRedisContainer:redis clue/redis-benchmark -t ping,set,get -l --csv | while IFS= read -r line; do printf '%s,%s\n' "$(date '+%s')" "$line"; done
