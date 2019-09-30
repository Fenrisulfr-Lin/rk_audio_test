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
# @desc sample rate test

#record time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result"
mkdir -p result_log
mkdir -p running_log
echo "$startTime" > result_log/rk_alsa_sample_rate_result.log

#features passes vs. features all
feature_pass=0
feature_cnt=0
feature_all=0

feature_test () 
{
	echo "============================================"
	echo -e "\n$feature_cnt:|LOG| CMD=$*"
	echo "-------------------------------------------"
	eval $* >tmp.log 2>&1
	eval_result=`echo "$?"`
	cat tmp.log
	if echo "$*" | grep alsabat ;then
		evaluate_result_alsabat $eval_result
	elif echo "$*" | grep speaker-test ;then
		evaluate_result_speaker_test $eval_result
	fi
}
evaluate_result_alsabat () 
{
	if [ $1 -eq 0 ]; then
		feature_pass=$((feature_pass+1))
		echo "$feature_cnt:|PASS| The test passed successfully"
		echo "alsabat_sample_rate_${TEST_RATE[$i]}:" "pass" \
			| tee -a result_log/rk_alsa_sample_rate_result.log
	else
		echo "$feature_cnt:|FAIL| Return code is $1." \
		"Fail samplie format is ${TEST_RATE[$i]}" 
		echo "alsabat_sample_rate_${TEST_RATE[$i]}:" "fail" \
			| tee -a result_log/rk_alsa_sample_rate_result.log
	fi
	feature_cnt=$((feature_cnt+1))
}

evaluate_result_speaker_test () 
{
	if [ $1 -eq 0 ]; then
		feature_pass=$((feature_pass+1))
		echo "$feature_cnt:|PASS| The test passed successfully"
		echo "speaker_sample_rate_${TEST_RATE[$i]}:" "pass" \
			| tee -a result_log/rk_alsa_sample_rate_result.log
	else
		echo "$feature_cnt:|FAIL| Return code is $1." \
		"Fail samplie format is ${TEST_RATE[$i]}" 
		echo "speaker_sample_rate_${TEST_RATE[$i]}:" "fail" \
			| tee -a result_log/rk_alsa_sample_rate_result.log
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
RATE_RANGE=`echo "$CAP_STRING" | grep -w RATE | tr -s " "`
echo "HW_RATE_RANGE is $RATE_RANGE"

RATE_RANGE_VALUE=`echo "$RATE_RANGE" | tr -s " " | cut -d " " -f 2,3 | \
  					cut -d "[" -f 2 | cut -d "(" -f 2 | \
					cut -d "]" -f 1 | cut -d ")" -f 1`
RATE_RANGE_VALUE_MIN=`echo "$RATE_RANGE_VALUE" | cut -d " " -f 1`
RATE_RANGE_VALUE_MAX=`echo "$RATE_RANGE_VALUE" | cut -d " " -f 2`

RATE_VALUE=(8000 11025 16000 22050 24000 32000 44100 48000 88200 96000 192000)

#Remove values that exceed the range of hardware supported sample rates
i=0
j=0
while [[ RATE_VALUE[$i] -ne '' ]]
do
	if [[ RATE_VALUE[$i] -lt RATE_RANGE_VALUE_MIN ]] || \
	   [[ RATE_VALUE[$i] -gt RATE_RANGE_VALUE_MAX ]];then
		let "i += 1"
	else
		TEST_RATE[$j]=${RATE_VALUE[$i]}
		let "i += 1"
		let "j += 1"
	fi
done
echo "TEST RATE is ${TEST_RATE[@]}"


#speaker-test.Need manual detection
i=0
while [[ TEST_RATE[$i] -ne '' ]]
do      
	feature_test speaker-test -r ${TEST_RATE[$i]} -l 2 -D $PLAY_DEVICE -c 2
	let "i += 1"
done
sleep 5


#alsabat test, requires external loopback,test hw:x,x
#Can automatically analyze test results.
i=0
sigma_k=30.0 ##Frequency detection threshold
while [[ TEST_RATE[$i] -ne '' ]]
do      
	feature_test alsabat -r ${TEST_RATE[$i]} \
			-k $sigma_k -D $PLAY_DEVICE -c 2
	let "i += 1"
done

#echo all test result 
echo "[$feature_pass/$feature_cnt] features passes." \
			| tee -a result_log/rk_alsa_sample_rate_result.log

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:" \
     "$sumTime_m minutes and $sumTime_s seconds" \
     | tee -a result_log/rk_alsa_sample_rate_result.log
