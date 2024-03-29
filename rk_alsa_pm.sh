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
# @desc Testing for power management S3 test

#record time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result"
mkdir -p result_log
mkdir -p running_log
echo "$startTime" > result_log/rk_alsa_pm_result.log

#features passes vs. features all
feature_pass=0
feature_cnt=0
feature_all=0

feature_test_power () 
{
	echo "============================================"
	echo -e "\n$feature_cnt:|LOG| CMD=$*"
	echo "-------------------------------------------"

	# run alsabat in the background
	nohup $* >tmp.log 2>&1 &
	sleep 2
	pid=`ps -aux |grep alsabat|head -1 |awk -F ' ' '{print $2}'`

	# stop the alsabat thread
	kill -STOP $pid > /dev/null
	sleep 4

	# do system S3
	sudo rtcwake -m mem -s 5
	sleep 2

	# resume the alasbat thread to run
	kill -CONT $pid > /dev/null

	# wait for alsabat to complete the analysis
	sleep 10

	cat tmp.log | grep -i "Return value is 0" > /dev/null
        eval_result=`echo "$?"`
        cat tmp.log
	evaluate_result $eval_result
}

evaluate_result () 
{
	if [ $1 -eq 0 ]; then
		feature_pass=$((feature_pass+1))
		echo "$feature_cnt:|PASS| The test passed successfully"
		echo "alsabat_pm_S3:" "pass" \
                	| tee -a result_log/rk_alsa_pm_result.log 
	else
		echo "$feature_cnt:|FAIL| Return code is $1." 
		echo "alsabat_pm_S3:" "fail" \
                	| tee -a result_log/rk_alsa_pm_result.log 
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


sigma_k=30.0 #Frequency detection threshold
#power management: S3 test
feature_test_power alsabat -D $PLAY_DEVICE -c $CHANNELS -n5s -k $sigma_k 


#echo all test result 
echo "[$feature_pass/$feature_cnt] features passes." \
				| tee -a result_log/rk_alsa_pm_result.log

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:" \
     "$sumTime_m minutes and $sumTime_s seconds" \
     | tee -a result_log/rk_alsa_pm_result.log
