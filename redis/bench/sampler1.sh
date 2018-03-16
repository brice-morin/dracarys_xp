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


declare -a all_cpus=(0.05 0.34 0.61 0.82 0.95 1 0.95 0.82 0.61 0.34)
index=0
while $alive; do
    mapfile -t targets < <(docker ps -q --format "{{.Names}}" --filter label=eu.stamp.dracarys=true)
    if [[ ${#targets[@]} -eq "0" ]]; then
      printf -v ts '%(%s)T' -1
      echo "$ts,_,no target" >> sampler1.log
      sleep 5s
      continue
    fi
    for (( i=0; i<${#targets[@]}; i++ )); do
      target=${targets[i]}
      cpus=${all_cpus[$index%${#all_cpus[@]}]}
      error=`docker update --cpus ${cpus} $target 2>&1 >> /dev/null`
      printf -v ts '%(%s)T' -1
      if [ $? -eq 0 ]; then
        echo "$ts,docker update --cpus ${cpus} $target,${error}" >> sampler1.log
        echo "$ts,${cpus},${target}" >> sampler1.sig
      else
        echo "$ts,docker update --cpus ${cpus} $target,${error}" >> sampler1.log
      fi
		done
    sleep 5s
    ((index++))
done
