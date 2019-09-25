#!/bin/bash
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
# @desc Testing for alsabat round trip latency mode.
#       One-way Latency may also test in the furture.

#record time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result"
echo "$startTime" > rk_alsa_latency_result.log

#features passes vs. features all
feature_pass=0
feature_cnt=0
feature_all=0

feature_test () 
{
	echo "============================================"
	echo -e "\n$feature_cnt:|LOG| CMD=$*" \
				| tee -a rk_alsa_latency_result.log
	echo "-------------------------------------------"
	eval $* >tmp.log 2>&1
	eval_result=`echo "$?"`
	cat tmp.log | tee -a rk_alsa_latency_result.log
	evaluate_result $eval_result
}
evaluate_result () 
{
	if [ $1 -eq 0 ]; then
		feature_pass=$((feature_pass+1))
		echo "$feature_cnt:|PASS| The test passed successfully" \
				| tee -a rk_alsa_latency_result.log
	else
		echo "$feature_cnt:|FAIL| Return code is $1 ." \
				| tee -a rk_alsa_latency_result.log
	fi
	feature_cnt=$((feature_cnt+1))
}

############################ Default Values for Params #########################
PLAYBACK_SOUND_CARDS=( $(aplay -l | grep -i card | grep -o '[0-9]\+:' | \
						cut -c 1 | awk 'FNR==1') )
PLAYBACK_SOUND_DEVICE=($(aplay -l | grep -i card | grep -o '[0-9]\+:' | \
						cut -c 1 | awk 'FNR==2') )
: ${PLAY_DEVICE:=$(echo "hw:${PLAYBACK_SOUND_CARDS},${PLAYBACK_SOUND_DEVICE}" |\
					 grep 'hw:[0-9]' || echo 'hw:0,0')}
echo "PLAY_DEVICE is $PLAY_DEVICE"

CAP_STRING=`aplay -D $PLAY_DEVICE --dump-hw-params -d 1 /dev/zero 2>&1`
CHANNELS=`echo "$CAP_STRING" | grep -w CHANNELS | cut -d ':' -f 2`
echo "HW_CHANNELS is $CHANNELS"


########################### round trip latency test ############################
echo "Need quiet environment without cooling fan"
feature_test alsabat -D $PLAY_DEVICE -c $CHANNELS --roundtriplatency \
                        -E 1024 -B 2048 


#echo all test result 
echo "[$feature_pass/$feature_cnt] features passes." \
				| tee -a rk_alsa_latency_result.log

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:" \
     "$sumTime_m minutes and $sumTime_s seconds" \
     | tee -a rk_alsa_latency_result.log
