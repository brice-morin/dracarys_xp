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


declare -a samples=(0.05 0.14 0.23 0.32 0.41 0.50 0.58 0.66 0.74 0.81 0.88 0.95 1.00 1.06 1.10 1.15 1.18 1.21 1.23 1.24 1.25 1.25 1.24 1.23 1.21 1.18 1.15 1.10 1.06 1.00 0.95 0.88 0.81 0.74 0.66 0.58 0.50 0.41 0.32 0.23 0.14)
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
