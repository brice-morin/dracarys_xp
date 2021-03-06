#! /bin/bash
alive=true
function _term {
  alive=false
  echo "Waiting 10sfor processes to terminate... Ctrl+C again to quit now."
  sleep 10s
  for job in `jobs -p`
  do
    #echo $job
    wait $job
  done
  echo "The End."
  exit
}

trap _term INT


declare -a samples=(0 1 3 5 7 8 9 9 9 9 9 8 7 5 4 2 0 0 0)
echo "--------" >> sampler3.log
echo "--------" >> sampler3.sig
while $alive; do
  for sample in "${samples[@]}"; do
    #echo $sample
    mapfile -t containers < <(docker ps -q --format "{{.Names}}" --filter label=eu.stamp.dracarys=true)
    if [[ ${#containers[@]} -eq "0" ]]; then
        printf -v ts '%(%s)T' -1
        echo "_ #$ts" >> sampler3.log
          sleep 10s
      continue
    fi
    for (( i=0; i<${#containers[@]}; i++ )); do
      container=${containers[i]}
      (if docker exec -d $container stress --hdd 16 --timeout ${sample}s --verbose ; then
        printf -v ts '%(%s)T' -1
        echo "docker exec -d $container stress --hdd 16 --timeout ${sample}s --verbose #$ts" >> sampler3.log
        echo "$ts,${sample},${container}" >> sampler3.sig
      fi)&
		done
      sleep 10s
  done
done
