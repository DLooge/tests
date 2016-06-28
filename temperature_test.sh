
#
# Ask for the number of devices to run the test on.
#
read -p "Number of devices to test for (0 for device query): " num_devices
num_devices=${num_devices:-0}

#
# Move to correct folder. Throw error and exit if cuda samples folder does not exist.
#
cuda_home=$CUDA_HOME
empty_string=""
if [ "$cuda_home" = "$empty_string" ];
then
    echo "CUDA_HOME does not exists as a system variable."
    exit 1
else
    cd $cuda_home
fi

if [ -d "samples" ]
then
    cd samples
else
    echo "samples folder not found. Are you sure you installed it?."
    exit 1
fi

#
# Run device query if num_devices was 0.
#
if [ $num_devices -eq 0 ]
then
    echo APA
    cd 1_Utilities/deviceQuery
    sudo make
    ./deviceQuery
    exit 1
fi

#
# If num_devices = 1, ask which specific device (run with 0, i.e. device query) if  
# you're uncertain which devices there are.
# 
echo "Testing for" $num_devices "devices"
device_loop_to=`expr $num_devices - 1`

if [ $num_devices -eq 1 ]
then
    read -p "Which device to you want to test for: " single_device
fi

#
# Set "heavyness" here. More calls = More load.
#
num_bandwidth_calls=4
num_nbody_calls=1

#
# Build the executables.
#
cd 1_Utilities/bandwidthTest/
sudo make
cd ../../
cd 5_Simulations/nbody
sudo make
cd ../../

#
# Loop over the devices and launch the tests (silently and asynchronously).
#
START=0
for device in $(eval echo "{$START..$device_loop_to}")
do
    echo $device
    if [ $num_devices -eq 1 ]
    then
	device=$single_device
    fi
    echo $device
    
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


echo "End of test. Run:    watch -n 1 nvidia-smi     for monitoring."

