#! /bin/bash
alive=true
function _term {
  alive=false
  echo "Waiting 2sfor processes to terminate... Ctrl+C again to quit now."
  sleep 2s
  for job in `jobs -p`
  do
    #echo $job
    wait $job
  done
  echo "The End."
  exit
}

trap _term INT


declare -a all_client=(1 32 63 93 121 147 172 193 212 227 238 246 250 250 246 238 227 212 193 172 147 121 93 63 32)
declare -a all_size=(1 5 8 10 10 9 6 3)
declare -a all_keyset=(10 99 188 276 361 443 522 597 667 732 791 844 890 929 961 984 1000 1008 1008 1000 984 961 929 890 844 791 732 667 597 522 443 361 276 188 99)
declare -a all_pipeline=(10 20 30 40 50 59 68 76 84 90 96 101 105 107 109 110 109 107 105 101 96 90 84 76 68 59 50 40 30 20)
declare -a targets=("MyRedisContainer")
index=0
while $alive; do
    if [[ ${#targets[@]} -eq "0" ]]; then
      printf -v ts '%(%s)T' -1
      echo "$ts,_,no target" >> redisbench.log
      sleep 2s
      continue
    fi
    for (( i=0; i<${#targets[@]}; i++ )); do
      target=${targets[i]}
      client=${all_client[$index%${#all_client[@]}]}
      size=${all_size[$index%${#all_size[@]}]}
      keyset=${all_keyset[$index%${#all_keyset[@]}]}
      pipeline=${all_pipeline[$index%${#all_pipeline[@]}]}
      error=`docker run --rm --link MyRedisContainer:redis clue/redis-benchmark -t ping,set,get -c ${client} -d ${size} -r ${keyset} -n 10000 -P ${pipeline} --csv | while IFS= read -r line; do printf '%s,%s\n' "$(date '+%s')" "$line"; done 2>&1 >> bench.log`
      printf -v ts '%(%s)T' -1
      if [ $? -eq 0 ]; then
        echo "$ts,docker run --rm --link MyRedisContainer:redis clue/redis-benchmark -t ping,set,get -c ${client} -d ${size} -r ${keyset} -n 10000 -P ${pipeline} --csv | while IFS= read -r line; do printf '%s,%s\n' "$(date '+%s')" "$line"; done,${error}" >> redisbench.log
        echo "$ts,${client},${size},${keyset},${pipeline},${target}" >> redisbench.sig
      else
        echo "$ts,docker run --rm --link MyRedisContainer:redis clue/redis-benchmark -t ping,set,get -c ${client} -d ${size} -r ${keyset} -n 10000 -P ${pipeline} --csv | while IFS= read -r line; do printf '%s,%s\n' "$(date '+%s')" "$line"; done,${error}" >> redisbench.log
      fi
		done
    sleep 2s
    ((index++))
done
