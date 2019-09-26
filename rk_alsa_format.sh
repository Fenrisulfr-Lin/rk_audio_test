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
# @desc format test

#record time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result"
echo "$startTime" > result_log/rk_alsa_format_result.log

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
	else 
		evaluate_result $eval_result
	fi
}
evaluate_result_alsabat () 
{
	if [ $1 -eq 0 ]; then
		feature_pass=$((feature_pass+1))
		echo "$feature_cnt:|PASS| The test passed successfully"
		echo "alsabat_format_${TEST_FORMAT[$i]}:" "pass" \
			| tee -a result_log/rk_alsa_format_result.log
	else
		echo "$feature_cnt:|FAIL| Return code is $1." \
		"Fail samplie format is ${TEST_FORMAT[$i]}" 
		echo "alsabat_format_${TEST_FORMAT[$i]}:" "fail" \
			| tee -a result_log/rk_alsa_format_result.log
	fi
	feature_cnt=$((feature_cnt+1))
}

evaluate_result_speaker_test () 
{
	if [ $1 -eq 0 ]; then
		feature_pass=$((feature_pass+1))
		echo "$feature_cnt:|PASS| The test passed successfully"
		echo "speaker_test_format_${TEST_FORMAT[$i]}:" "pass" \
			| tee -a result_log/rk_alsa_format_result.log
	else
		echo "$feature_cnt:|FAIL| Return code is $1." \
		"Fail samplie format is ${TEST_FORMAT[$i]}" 
		echo "speaker_test_format_${TEST_FORMAT[$i]}:" "fail" \
			| tee -a result_log/rk_alsa_format_result.log
	fi
	feature_cnt=$((feature_cnt+1))
}

evaluate_result () 
{
	flag=`echo $log | grep "Does not exists or has size zero"`
	if [ -n "$flag" ];then
		echo "$feature_cnt:|FAIL| Return code is 2." \
		     "Fail samplie format is ${TEST_FORMAT[$i]}" 
		echo "alsa_${TEST_TYPE[$j]}_format_${TEST_FORMAT[$i]}:" "fail" \
			| tee -a result_log/rk_alsa_format_result.log
	else
		if [ $1 -eq 0 ]; then
			feature_pass=$((feature_pass+1))
			echo "$feature_cnt:|PASS| The test passed successfully"
			echo "alsa_${TEST_TYPE[$j]}_format_${TEST_FORMAT[$i]}:" "pass" \
				| tee -a result_log/rk_alsa_format_result.log
		else
			echo "$feature_cnt:|FAIL| Return code is $1." \
			"Fail samplie format is ${TEST_FORMAT[$i]}" 
			echo "alsa_${TEST_TYPE[$j]}_format_${TEST_FORMAT[$i]}:" "fail" \
				| tee -a result_log/rk_alsa_format_result.log
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
FORMAT_RANGE=`echo "$CAP_STRING" | grep -w FORMAT | tr -s " "`
echo "HW_FORMAT_RANGE is $FORMAT_RANGE"

FORMAT_RANGE_VALUE=`echo "$FORMAT_RANGE" | tr -s " " | cut -d " " -f 2-`
TEST_FORMAT=($FORMAT_RANGE_VALUE)
echo "TEST FORMAT is ${TEST_FORMAT[@]}"


#capture/playback test.
#The test result can be given automatically, 
#but it is only judged whether the capture/playback
#is successful under the setting.
ARECORD_WAVE_HEADER_SUPPORT_FORMAT="U8 S16_LE S32_LE FLOAT_LE S24_LE S24_3LE"
TEST_TYPE=(capture playback)
i=0
while [[ -n ${TEST_FORMAT[$i]} ]]
do
	if [[ $ARECORD_WAVE_HEADER_SUPPORT_FORMAT == *${TEST_FORMAT[$i]}* ]];
	then
		j=0
		while [[ -n ${TEST_TYPE[$j]} ]]
		do
			feature_test bash rk_alsa_test_tool.sh \
				-t ${TEST_TYPE[$j]} -f ${TEST_FORMAT[$i]} -F \
				ALSA_FORMAT_${TEST_FORMAT[$i]}.snd -d 5
			let "j += 1"
		done
	else
		echo -e "\n|NOT SUPPORT| ${TEST_FORMAT[$i]} format is"\
		     "not supported, when the arecord write a WAVE-header"
		echo "alsa_capture_format_${TEST_FORMAT[$i]}:" "skip" \
                	| tee -a result_log/rk_alsa_format_result.log
		echo "alsa_playback_format_${TEST_FORMAT[$i]}:" "skip" \
                	| tee -a result_log/rk_alsa_format_result.log
	fi
	let "i += 1"
done
sleep 5


#speaker-test.Need manual detection
SPEAKER_TEST_SUPPORT_FORMAT="S8 S16_LE S16_BE FLOAT_LE \
				S24_3LE S24_3BE S32_LE S32_BE"
i=0
while [[ -n ${TEST_FORMAT[$i]} ]]
do	
	if [[ $SPEAKER_TEST_SUPPORT_FORMAT == *${TEST_FORMAT[$i]}* ]];
	then
		feature_test speaker-test --format ${TEST_FORMAT[$i]} \
						-l 2 -D $PLAY_DEVICE -c 2
	else
		echo -e "\n|NOT SUPPORT| speaker-test"\
			"does not support ${TEST_FORMAT[$i]} format"
		echo "speaker_test_format_${TEST_FORMAT[$i]}:" "skip" \
			| tee -a result_log/rk_alsa_format_result.log
	fi
	let "i += 1"
done
sleep 5


#alsabat test, requires external loopback,test hw:x,x
#Can automatically analyze test results.
ALSABAT_SUPPORT_FORMAT="U8 S16_LE S24_3LE S32_LE"
i=0
sigma_k=30.0 ##Frequency detection threshold
while [[ -n ${TEST_FORMAT[$i]} ]]
do
	if [[ $ALSABAT_SUPPORT_FORMAT == *${TEST_FORMAT[$i]}* ]];
	then
		feature_test alsabat -f ${TEST_FORMAT[$i]} \
					-k $sigma_k -D $PLAY_DEVICE -c 2
	else
		echo -e "\n|NOT SUPPORT| alsabat does"\
			"not support ${TEST_FORMAT[$i]} format"
		echo "alsabat_format_${TEST_FORMAT[$i]}:" "skip" \
			| tee -a result_log/rk_alsa_format_result.log
	fi					
	let "i += 1"
done


echo "[$feature_pass/$feature_cnt] features passes." \
				| tee -a result_log/rk_alsa_format_result.log

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:" \
     "$sumTime_m minutes and $sumTime_s seconds" \
     | tee -a result_log/rk_alsa_format_result.log
