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


declare -a samples=( 919 958 984 998 998 984 958 919 867 804 730 646 554 454 348 238 124 10 124 238 348 454 554 646 730 804 867)
echo "--------" >> sampler3.log
echo "--------" >> sampler3.sig
while $alive; do
  for sample in "${samples[@]}"; do
    #echo $sample
    mapfile -t containers < <(docker ps -q --format "{{.Names}}" --filter label=eu.stamp.dracarys=true)
    if [[ ${#containers[@]} -eq "0" ]]; then
        printf -v ts '%(%s)T' -1
        echo "_ #$ts" >> sampler3.log
          sleep 5s
      continue
    fi
    for (( i=0; i<${#containers[@]}; i++ )); do
      container=${containers[i]}
      (if docker update --blkio-weight ${sample} $container ; then
        printf -v ts '%(%s)T' -1
        echo "docker update --blkio-weight ${sample} $container #$ts" >> sampler3.log
        echo "$ts,${sample},${container}" >> sampler3.sig
      fi)&
		done
      sleep 5s
  done
done
