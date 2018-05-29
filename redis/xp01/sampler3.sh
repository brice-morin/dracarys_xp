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


declare -a all_blkio_weight=(784 627 439 230 10 230 439 627 784 901 975 1000 975 901)
index=0
while $alive; do
    mapfile -t targets < <(docker ps -q --format "{{.Names}}" --filter label=eu.stamp.dracarys=true)
    if [[ ${#targets[@]} -eq "0" ]]; then
      printf -v ts '%(%s)T' -1
      echo "$ts,_,no target" >> sampler3.log
      sleep 5s
      continue
    fi
    for (( i=0; i<${#targets[@]}; i++ )); do
      target=${targets[i]}
      blkio_weight=${all_blkio_weight[$index%${#all_blkio_weight[@]}]}
      error=`docker update --blkio-weight ${blkio_weight} $target 2>&1 >> /dev/null`
      printf -v ts '%(%s)T' -1
      if [ $? -eq 0 ]; then
        echo "$ts,docker update --blkio-weight ${blkio_weight} $target,${error}" >> sampler3.log
        echo "$ts,${blkio_weight},${target}" >> sampler3.sig
      else
        echo "$ts,docker update --blkio-weight ${blkio_weight} $target,${error}" >> sampler3.log
      fi
		done
    sleep 5s
    ((index++))
done
