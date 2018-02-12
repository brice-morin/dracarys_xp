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


declare -a samples=(8.00 11.42 14.76 17.97 20.98 23.72 26.14 28.19 29.83 31.03 31.76 32.00 31.76 31.03 29.83 28.19 26.14 23.72 20.98 17.97 14.76 11.42)
echo "--------" >> sampler2.log
echo "--------" >> sampler2.sig
while $alive; do
  for sample in "${samples[@]}"; do
    #echo $sample
    mapfile -t containers < <(docker ps -q --format "{{.Names}}" --filter label=eu.stamp.dracarys=true)
    if [[ ${#containers[@]} -eq "0" ]]; then
        printf -v ts '%(%s)T' -1
        echo "_ #$ts" >> sampler2.log
          sleep 5s
      continue
    fi
    for (( i=0; i<${#containers[@]}; i++ )); do
      container=${containers[i]}
      (if docker update --memory ${sample}m $container ; then
        printf -v ts '%(%s)T' -1
        echo "docker update --memory ${sample}m $container #$ts" >> sampler2.log
        echo "$ts,${sample},${container}" >> sampler2.sig
      fi)&
		done
      sleep 5s
  done
done
