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


declare -a samples=(32.00 80.05 127.61 174.21 219.39 262.68 303.65 341.90 377.04 408.70 436.59 460.41 479.93 494.95 505.31 510.93 511.73 507.72 498.92 485.44 467.40 444.99 418.43 387.99 353.98 316.73 276.62 234.05 189.45 143.27 95.98 48.04)
echo "--------" >> sampler2.log
echo "--------" >> sampler2.sig
while $alive; do
  for sample in "${samples[@]}"; do
    #echo $sample
    mapfile -t containers < <(docker ps -q --format "{{.Names}}" --filter label=eu.stamp.dracarys=true)
    if [[ ${#containers[@]} -eq "0" ]]; then
        printf -v ts '%(%s)T' -1
        echo "_ #$ts" >> sampler2.log
          sleep 15s
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
      sleep 15s
  done
done
