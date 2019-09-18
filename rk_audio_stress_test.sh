#! /bin/bash
#
# Copyright (C) 2019 Fuzhou Rockchip Electronics Co.,Ltd
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as 
# published by the Free Software Foundation version 2.
#
# This program is distributed "as is" WITHOUT ANY WARRANTY of any
# kind, whether express or implied; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# @desc Artificially build a high-load environment and stress test audio


#record time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result"
echo "$startTime"

CAPTURE_SOUND_CARDS=( $(arecord -l | grep -i card | grep -o '[0-9]\+:' |\
                                                cut -c 1 | awk 'FNR==1') )
CAPTURE_SOUND_DEVICE=($(arecord -l | grep -i card | grep -o '[0-9]\+:' |\
                                                cut -c 1 | awk 'FNR==2') )
: ${REC_DEVICE:=$(echo "hw:${CAPTURE_SOUND_CARDS},${CAPTURE_SOUND_DEVICE}" |\
                                         grep 'hw:[0-9]' || echo 'hw:0,0')}

PLAYBACK_SOUND_CARDS=( $(aplay -l | grep -i card | grep -o '[0-9]\+:' |\
                                                cut -c 1 | awk 'FNR==1') )
PLAYBACK_SOUND_DEVICE=($(aplay -l | grep -i card | grep -o '[0-9]\+:' |\
                                                cut -c 1 | awk 'FNR==2') )
: ${PLAY_DEVICE:=$(echo "hw:${PLAYBACK_SOUND_CARDS},${PLAYBACK_SOUND_DEVICE}" |\
                                         grep 'hw:[0-9]' || echo 'hw:0,0')}

echo "==================AUDIO DEV INFO=================="
aplay -l
arecord -l

cpu_num=`cat /proc/stat | grep cpu[0-9] -c`
echo "cpu_num : $cpu_num"

echo "================start loopback test==============="

echo "REC_DEVICE : $REC_DEVICE"
echo "PLAY_DEVICE : $PLAY_DEVICE"

DD_TIMES=15 #dd command execution times
COUNT=1024 #dd command to transfer file size in megabytes
echo "dd command execution times : $DD_TIMES"
echo "dd command to transfer file size : $COUNT MB"
TEST_TIME=$[ $DD_TIMES * 2 ]

arecord -D $REC_DEVICE -f S16_LE -d 20 -c 2 | \
                                aplay -D $PLAY_DEVICE -f S16_LE -d 20 -c 2 &
#speaker-test -t wav -l $DD_TIMES &> /dev/null &


j=0
while [[ $j -lt $DD_TIMES ]] 
do
        #Calculate the starting value
        start=$(cat /proc/stat | grep "cpu " | \
                awk '{print $2" "$3" "$4" "$5" "$6" "$7" "$8}')
        start_idle=$(echo ${start} | awk '{print $4}')
        start_total=$(echo ${start} | awk '{printf "%.f",$1+$2+$3+$4+$5+$6+$7}')

        #Running in the background, increasing the load
	dd if=/dev/urandom of=/dev/null bs=1M count=$COUNT &> /dev/null &
	sleep 1

        #Calculate the end value
        end=$(cat /proc/stat | grep "cpu " | \
              awk '{print $2" "$3" "$4" "$5" "$6" "$7" "$8}')
        end_idle=$(echo ${end} | awk '{print $4}')
        end_total=$(echo ${end} | awk '{printf "%.f",$1+$2+$3+$4+$5+$6+$7}')

        #Compare the start and end values to get instant CPU usage
        idle=`expr ${end_idle} - ${start_idle[$i]}`
        total=`expr ${end_total} - ${start_total[$i]}`
        idle_normal=`expr ${idle} \* 100`
        cpu_idle=`expr ${idle_normal} / ${total}`
        cpu_rate=`expr 100 - ${cpu_idle}`

	dd_num=$(ps | grep dd | wc -l)
	echo "The number of running dd processes : $dd_num"
	echo "cpu_used : $cpu_rate%"

	let "j += 1"
done

k=0 
while [[ $k -lt $DD_TIMES ]]
do
        dd_pid="$(ps | grep -w dd | awk '{print $1}' | awk 'FNR==1')"

	if [ ! -n "$dd_pid" ];then
		break
	else
		#echo "dd_pid : $dd_pid"
        	kill $dd_pid 
	fi
	let "k += 1"
done

dd_num=$(ps | grep dd | wc -l)
echo "The cleaning is completed,the number of remaining dd processes is $dd_num"

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:" \
     "$sumTime_m minutes and $sumTime_s seconds"