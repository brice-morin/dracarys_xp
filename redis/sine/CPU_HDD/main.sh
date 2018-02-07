#! /bin/bash
trap "kill 0" SIGINT SIGTERM

(./sampler1.sh) &
(./sampler3.sh) &

wait
