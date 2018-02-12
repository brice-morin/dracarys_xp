#! /bin/bash
declare -a samples=(10 20 30)
#TODO: mount a crash cart on all containers (with --filter)
#trap "echo Booh!" SIGINT SIGTERM #TODO unmount crash cart and exit
while true; do
  for sample in "${samples[@]}"; do
    echo $sample
    for container in `docker ps -q --format "{{.Names}}""$@"`; do #"$@" should be --filter options valid for docker ps, see https://docs.docker.com/engine/reference/commandline/ps/#filtering
      if docker exec -d $container stress --cpu 16 --timeout ${sample}s --verbose ; then
        printf -v ts '%(%s)T' -1
        echo "docker exec -d $container stress --cpu 16 --timeout ${sample}s --verbose #$ts" >> script.sh
      fi
      if docker exec -d $container stress --vm 16 --timeout ${sample}s --verbose ; then
        printf -v ts '%(%s)T' -1
        echo "docker exec -d $container stress --vm 16 --timeout ${sample}s --verbose #$ts" >> script.sh
      fi
      if docker exec -d $container stress --io 16 --timeout ${sample}s --verbose ; then
        printf -v ts '%(%s)T' -1
        echo "docker exec -d $container stress --io 16 --timeout ${sample}s --verbose #$ts" >> script.sh
      fi
      if docker exec -d $container stress --hdd 16 --timeout ${sample}s --verbose ; then
        printf -v ts '%(%s)T' -1
        echo "docker exec -d $container stress --hdd 16 --timeout ${sample}s --verbose #$ts" >> script.sh
      fi

      #https://github.com/tylertreat/Comcast

    done
    sleep 30s
  done
done
