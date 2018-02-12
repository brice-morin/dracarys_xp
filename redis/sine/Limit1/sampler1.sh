#! /bin/bash
alive=true
function _term {
  alive=false
  echo "Waiting 15sfor processes to terminate... Ctrl+C again to quit now."
  sleep 15s
  for job in `jobs -p`
  do
    #echo $job
    wait $job
  done
  echo "The End."
  exit
}

trap _term INT


declare -a samples=(0.10 0.55 0.99 1.42 1.83 2.22 2.58 2.91 3.20 3.45 3.66 3.82 3.93 3.99 4.00 3.95 3.86 3.72 3.53 3.29 3.01 2.69 2.34 1.96 1.56 1.13 0.70 0.25)
echo "--------" >> sampler1.log
echo "--------" >> sampler1.sig
while $alive; do
  for sample in "${samples[@]}"; do
    #echo $sample
    mapfile -t containers < <(docker ps -q --format "{{.Names}}" --filter label=eu.stamp.dracarys=true)
    if [[ ${#containers[@]} -eq "0" ]]; then
        printf -v ts '%(%s)T' -1
        echo "_ #$ts" >> sampler1.log
          sleep 15s
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
      sleep 15s
  done
done
