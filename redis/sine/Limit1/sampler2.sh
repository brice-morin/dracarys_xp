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


declare -a samples=(16.00 21.34 26.66 31.93 37.14 42.24 47.23 52.08 56.77 61.28 65.58 69.66 73.51 77.09 80.41 83.43 86.16 88.57 90.65 92.41 93.82 94.89 95.60 95.96 95.96 95.60 94.89 93.82 92.41 90.65 88.57 86.16 83.43 80.41 77.09 73.51 69.66 65.58 61.28 56.77 52.08 47.23 42.24 37.14 31.93 26.66 21.34)
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
