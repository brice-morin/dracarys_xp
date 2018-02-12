#! /bin/bash
alive=true
function _term {
  alive=false
  echo "Waiting 5sfor processes to terminate... Ctrl+C again to quit now."
  sleep 5s
  for job in `jobs -p`
  do
    #echo $job
    wait $job
  done
  echo "The End."
  exit
}

trap _term INT


declare -a samples=(0.05 0.22 0.39 0.55 0.69 0.81 0.90 0.96 1.00 1.00 0.96 0.90 0.81 0.69 0.55 0.39 0.22)
echo "--------" >> sampler1.log
echo "--------" >> sampler1.sig
while $alive; do
  for sample in "${samples[@]}"; do
    #echo $sample
    mapfile -t containers < <(docker ps -q --format "{{.Names}}" --filter label=eu.stamp.dracarys=true)
    if [[ ${#containers[@]} -eq "0" ]]; then
        printf -v ts '%(%s)T' -1
        echo "_ #$ts" >> sampler1.log
          sleep 5s
      continue
    fi
    for (( i=0; i<${#containers[@]}; i++ )); do
      container=${containers[i]}
      (if docker update --cpus ${sample} $container ; then
        printf -v ts '%(%s)T' -1
        echo "docker update --cpus ${sample} $container #$ts" >> sampler1.log
        echo "$ts,${sample},${container}" >> sampler1.sig
      fi)&
		done
      sleep 5s
  done
done
