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


declare -a all_memory=(61.96 64 61.96 55.96 46.43 34 19.53 4 19.53 34 46.43 55.96)
index=0
while $alive; do
    mapfile -t targets < <(docker ps -q --format "{{.Names}}" --filter label=eu.stamp.dracarys=true)
    if [[ ${#targets[@]} -eq "0" ]]; then
      printf -v ts '%(%s)T' -1
      echo "$ts,_,no target" >> sampler2.log
      sleep 5s
      continue
    fi
    for (( i=0; i<${#targets[@]}; i++ )); do
      target=${targets[i]}
      memory=${all_memory[$index%${#all_memory[@]}]}
      error=`docker update --memory ${memory}m $target 2>&1 >> /dev/null`
      printf -v ts '%(%s)T' -1
      if [ $? -eq 0 ]; then
        echo "$ts,docker update --memory ${memory}m $target,${error}" >> sampler2.log
        echo "$ts,${memory},${target}" >> sampler2.sig
      else
        echo "$ts,docker update --memory ${memory}m $target,${error}" >> sampler2.log
      fi
		done
    sleep 5s
    ((index++))
done
