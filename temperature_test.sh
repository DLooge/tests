
read -p "Number of devices to test for: " num_devices
num_devices=${num_devices:-0}
echo "Testing for" $num_devices "devices"

num_devices=`expr $num_devices - 1`

cd $CUDA_HOME
cd samples

START=0

num_bandwidth_calls=1
num_nbody_calls=1

for device in $(eval echo "{$START..$num_devices}")
do	
	echo "Beginning tests for device" $device
	echo

	echo "Beginning" $num_bandwidth_calls "bandwidth calls."
	echo
	for bandwidth_call in $(eval echo "{1..$num_bandwidth_calls}")
	do
		nohup ./1_Utilities/bandwidthTest/bandwidthTest -device=$device -dtod -mode=range -start=104857600 -end=104857700 -increment=1 > /dev/null 2>&1 &
	done

	echo "Beginning" $num_nbody_calls "nbody calls."
	echo
	for bandwidth_call in $(eval echo "{1..$num_body_calls}")
	do
		nohup ./5_Simulations/nbody/nbody -device=$device -benchmark -numbodies=1048576 > /dev/null 2>&1 &
	done
done


