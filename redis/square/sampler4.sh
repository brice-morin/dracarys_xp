#! /bin/bash
alive=true
function _term {
  alive=false
  echo "Waiting 1sfor processes to terminate... Ctrl+C again to quit now."
  sleep 1s
  for job in `jobs -p`
  do
    #echo $job
    wait $job
  done
  echo "The End."
  exit
}

trap _term INT


declare -a samples=(1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0)
echo "--------" >> sampler4.log
echo "--------" >> sampler4.sig
while $alive; do
  for sample in "${samples[@]}"; do
    #echo $sample
    mapfile -t containers < <(docker ps -q --format "{{.Names}}" --filter label=eu.stamp.dracarys=true)
    if [[ ${#containers[@]} -eq "0" ]]; then
        printf -v ts '%(%s)T' -1
        echo "_ #$ts" >> sampler4.log
          sleep 1s
      continue
    fi
    for (( i=0; i<${#containers[@]}; i++ )); do
      container=${containers[i]}
      (if docker exec -d $container stress --io 16 --timeout ${sample}s --verbose ; then
        printf -v ts '%(%s)T' -1
        echo "docker exec -d $container stress --io 16 --timeout ${sample}s --verbose #$ts" >> sampler4.log
        echo "$ts,${sample},${container}" >> sampler4.sig
      fi)&
		done
      sleep 1s
  done
done