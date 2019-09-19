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
# @desc sample rate test

#record time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result"
echo "$startTime" > rk_alsa_sample_rate_test_result.log

#features passes vs. features all
feature_pass=0
feature_cnt=0
feature_all=0

feature_test () 
{
	echo "============================================"
	
	echo "$feature_cnt : |LOG|CMD=$1" \
		| tee -a rk_alsa_sample_rate_test_result.log
	echo "-------------------------------------------"
	eval $1
	evaluate_result $?
}
evaluate_result () 
{
	feature_cnt=$((feature_cnt+1))
	if [ $1 -eq 0 ]; then
		feature_pass=$((feature_pass+1))
		echo "|PASS|:$1 passed." \
		      | tee -a rk_alsa_sample_rate_test_result.log
	else
		echo "|FAIL|:$1 failed. Return code is $RESULT" \
		     "FAIL sampling rate : ${TEST_RATE[$i]}"\
		      | tee -a rk_alsa_sample_rate_test_result.log
	fi
}

############################ Default Values for Params #########################
PLAYBACK_SOUND_CARDS=( $(aplay -l | grep -i card | grep -o '[0-9]\+:' | \
						cut -c 1 | awk 'FNR==1') )
PLAYBACK_SOUND_DEVICE=($(aplay -l | grep -i card | grep -o '[0-9]\+:' | \
						cut -c 1 | awk 'FNR==2') )
: ${PLAY_DEVICE:=$(echo "hw:${PLAYBACK_SOUND_CARDS},${PLAYBACK_SOUND_DEVICE}" |\
					 grep 'hw:[0-9]' || echo 'hw:0,0')}


TEST_RATE=(8000 11025 16000 22050 24000 32000 44100 48000 88200 96000 192000)

#speaker-test.Need manual detection
i=0
while [[ TEST_RATE[$i] -ne '' ]]
do      
	feature_test "speaker-test -r ${TEST_RATE[$i]} \
			-l 2 -D $PLAY_DEVICE -c 2" 
	let "i += 1"
done
sleep 5


#capture/playback test.
#The test result can be given automatically, 
#but it is only judged whether the capture/playback/loopback
#is successful under the setting.
i=0
while [[ TEST_RATE[$i] -ne '' ]]
do      
	feature_test "bash rk_alsa_test_tool.sh -t capture -r ${TEST_RATE[$i]}\
			-F ALSA_SAMPLE_RATE_${TEST_RATE[$i]}.snd -d 5"

        feature_test "bash rk_alsa_test_tool.sh -t playback -r ${TEST_RATE[$i]}\
        		-F ALSA_SAMPLE_RATE_${TEST_RATE[$i]}.snd -d 5"	
	let "i += 1"
done
sleep 5

#alsabat test, requires external loopback,test plughw:x,x
#Can automatically analyze test results.

i=0
sigma_k=30.0 ##Frequency detection threshold
while [[ TEST_RATE[$i] -ne '' ]]
do      
	feature_test "alsabat -r ${TEST_RATE[$i]} -k $sigma_k" 
	let "i += 1"
done



echo "[$feature_pass/$feature_cnt] features passes." \
				| tee -a rk_alsa_sample_rate_test_result.log

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:" \
     "$sumTime_m minutes and $sumTime_s seconds" \
     | tee -a rk_alsa_sample_rate_test_result.log
