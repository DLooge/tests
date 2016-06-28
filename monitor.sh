xterm -e nvidia-smi --format=csv --query-gpu=timestamp,gpu_uuid,name,power.draw,temperature.gpu,fan.speed,pstate,utilization.gpu,utilization.memory -l 1 &

xterm -e watch -n 1 nvidia-smi &

xterm -e watch -n 1 sensors &

xterm -e htop &
