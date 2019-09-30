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
# @desc Testing for various period sizes

#record time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result"
mkdir -p result_log
mkdir -p tmp_snd
mkdir -p running_log
echo "$startTime" > result_log/rk_alsa_period_size_result.log

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
	else
		evaluate_result $eval_result
	fi
}

evaluate_result_alsabat () 
{
        underrun_num=`cat tmp.log | grep -o -i Underrun | wc -l`
        overrun_num=`cat tmp.log | grep -o -i Overrun | wc -l`
        echo "$feature_cnt:|LOG| Underrun num is $underrun_num"
        echo "$feature_cnt:|LOG| Overrun num is $overrun_num" 

	if [ $1 -eq 0 ]; then
		feature_pass=$((feature_pass+1))
		echo "$feature_cnt:|PASS| The test passed successfully"
		echo "alsabat_period_size_${TEST_PERIOD_SIZE[$i]}:" "pass" \
                	| tee -a result_log/rk_alsa_period_size_result.log
	else
		echo "$feature_cnt:|FAIL| Return code is $1 ." \
		"Fail period size is ${TEST_PERIOD_SIZE[$i]}"
		echo "alsabat_period_size_${TEST_PERIOD_SIZE[$i]}:" "fail" \
                	| tee -a result_log/rk_alsa_period_size_result.log
	fi
	feature_cnt=$((feature_cnt+1))
}


evaluate_result () 
{
        underrun_num=`cat tmp.log | grep -o -i Underrun | wc -l`
        overrun_num=`cat tmp.log | grep -o -i Overrun | wc -l`
        echo "$feature_cnt:|LOG| Underrun num is $underrun_num"
        echo "$feature_cnt:|LOG| Overrun num is $overrun_num" 

	#Determine if period_size is automatically converted
	period_size_actual=`cat tmp.log | grep period_size | cut -d ':' -f 2` 
	if [[ $period_size_actual != *${TEST_PERIOD_SIZE[$i]}* ]] \
					&& [[ $period_size_actual -ne '' ]];then
		echo "$feature_cnt:|FAIL| Return code is $1 ." \
		     "Fail period size is ${TEST_PERIOD_SIZE[$i]}" 
		echo "|Auto-conversion| period_size from " \
		     "${TEST_PERIOD_SIZE[$i]} converted to $period_size_actual"
		echo "alsa_${TEST_TYPE[$j]}_period_size_${TEST_PERIOD_SIZE[$i]}:" "fail" \
                	| tee -a result_log/rk_alsa_period_size_result.log
	else
		if [ $1 -eq 0 ]; then
			feature_pass=$((feature_pass+1))
			echo "$feature_cnt:|PASS| The test passed successfully"
			echo "alsa_${TEST_TYPE[$j]}_period_size_${TEST_PERIOD_SIZE[$i]}:" "pass" \
                		| tee -a result_log/rk_alsa_period_size_result.log
		else
			echo "$feature_cnt:|FAIL| Return code is $1 ." \
			"Fail period size is ${TEST_PERIOD_SIZE[$i]}" 
			echo "alsa_${TEST_TYPE[$j]}_period_size_${TEST_PERIOD_SIZE[$i]}:" "fail" \
                		| tee -a result_log/rk_alsa_period_size_result.log
		fi
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
PERIOD_SIZE_RANGE=`echo "$CAP_STRING" | grep -w PERIOD_SIZE | tr -s " "`
echo "HW_PERIOD_SIZE_RANGE is $PERIOD_SIZE_RANGE"

PERIOD_SIZE_RANGE_VALUE=`echo "$PERIOD_SIZE_RANGE" | tr -s " " | \
                                        cut -d " " -f 2,3 | 
  					cut -d "[" -f 2 | cut -d "(" -f 2 | \
					cut -d "]" -f 1 | cut -d ")" -f 1`
PERIOD_SIZE_RANGE_VALUE_MIN=`echo "$PERIOD_SIZE_RANGE_VALUE" | cut -d " " -f 1`
PERIOD_SIZE_RANGE_VALUE_MAX=`echo "$PERIOD_SIZE_RANGE_VALUE" | cut -d " " -f 2`

PERIOD_SIZE_VALUE=(1 2 4 8 16 32 64 128 256 512 1024 2048 4096 \
                   8192 16384 32768 65536 131072 262144 524288 1048576) #2^20

#Remove values that exceed the range of hardware supported period size
i=0
j=0
while [[ PERIOD_SIZE_VALUE[$i] -ne '' ]]
do
	if [[ PERIOD_SIZE_VALUE[$i] -lt PERIOD_SIZE_RANGE_VALUE_MIN ]] || \
	   [[ PERIOD_SIZE_VALUE[$i] -gt PERIOD_SIZE_RANGE_VALUE_MAX ]];then
		let "i += 1"
	else
		TEST_PERIOD_SIZE[$j]=${PERIOD_SIZE_VALUE[$i]}
		let "i += 1"
		let "j += 1"
	fi
done
echo "TEST PERIOD_SIZE is ${TEST_PERIOD_SIZE[@]}"


#alsabat test, requires external loopback,test hw:x,x
#Can automatically analyze test results.
i=0
sigma_k=30.0 ##Frequency detection threshold
ALSABAT_SUPPORT_PERIOD_SIZE_MIN=32
ALSABAT_SUPPORT_PERIOD_SIZE_MAX=200000

while [[ TEST_PERIOD_SIZE[$i] -ne '' ]]
do      
	if [[ TEST_PERIOD_SIZE[$i] -le ALSABAT_SUPPORT_PERIOD_SIZE_MAX ]] && \
	   [[ TEST_PERIOD_SIZE[$i] -ge ALSABAT_SUPPORT_PERIOD_SIZE_MIN ]];
	then
		feature_test alsabat -E ${TEST_PERIOD_SIZE[$i]} \
				-k $sigma_k -D $PLAY_DEVICE -c 2
	else
		echo -e "\n|NOT SUPPORT| alsabat does"\
		"not support ${TEST_PERIOD_SIZE[$i]} period size"
		echo "alsabat_period_size_${TEST_PERIOD_SIZE[$i]}:" "skip" \
                	| tee -a result_log/rk_alsa_period_size_result.log
	fi
	let "i += 1"
done

#capture/playback test.
#The test result can be given automatically, 
#but it is only judged whether the capture/playback
#is successful under the setting.
TEST_TYPE=(capture playback)
i=0
while [[ TEST_PERIOD_SIZE[$i] -ne '' ]]
do
        j=0
	while [[ -n ${TEST_TYPE[$j]} ]]
	do
		feature_test bash rk_alsa_test_tool.sh -t ${TEST_TYPE[$j]} -p \
			${TEST_PERIOD_SIZE[$i]} -F \
			tmp_snd/ALSA_PERIOD_SIZE_${TEST_PERIOD_SIZE[$i]}.snd -v 1
		let "j += 1"
	done
	let "i += 1"
done



#echo all test result 
echo "[$feature_pass/$feature_cnt] features passes." \
			| tee -a result_log/rk_alsa_period_size_result.log

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:" \
     "$sumTime_m minutes and $sumTime_s seconds" \
     | tee -a result_log/rk_alsa_period_size_result.log
