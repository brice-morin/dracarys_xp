#! /bin/bash
trap "kill 0" SIGINT SIGTERM

(./sampler1.sh) &
(./sampler2.sh) &
(./sampler3.sh) &
(./redisbench.sh) &

wait
