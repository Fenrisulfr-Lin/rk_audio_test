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
# @desc Testing for noise detect

#record time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result"
mkdir -p result_log
echo "$startTime" > result_log/rk_alsa_noise_result.log

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
	evaluate_result_alsabat $eval_result
}
evaluate_result_alsabat () 
{
        flag=`cat tmp.log | grep -i 'Average SNR'`
        if [[ $flag != '' ]]; then
                feature_pass=$((feature_pass+1))
		snr=`echo "$flag" | cut -d ' ' -f 4`

                echo "$feature_cnt:|PASS| $flag" 
		echo "$feature_cnt:|PASS| The test passed successfully" 
		echo "alsabat_noise_snr_threshold_${TEST_SNR_THRESHOLD[$i]}:" "pass" "$snr" "dB"\
			| tee -a result_log/rk_alsa_noise_result.log
	else
		echo "$feature_cnt:|FAIL| Return code is $1."
		echo "alsabat_noise_snr_threshold_${TEST_SNR_THRESHOLD[$i]}:" "fail"\
			| tee -a result_log/rk_alsa_noise_result.log
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

#The threshold set by --snr-db, below which the value is judged as noise
TEST_SNR_THRESHOLD=(5 10 20 30) 
i=0
while [[ -n ${TEST_SNR_THRESHOLD[$i]} ]]
do
	feature_test alsabat -D $PLAY_DEVICE -c $CHANNELS \
			--snr-db ${TEST_SNR_THRESHOLD[$i]} -k $sigma_k 
	let "i += 1"
done

#--snr-pc just different units, no need for repeated testing
#feature_test alsabat -D $PLAY_DEVICE -c $CHANNELS --snr-pc 15 -k $sigma_k


#echo all test result 
echo "[$feature_pass/$feature_cnt] features passes." \
				| tee -a result_log/rk_alsa_noise_result.log

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:" \
     "$sumTime_m minutes and $sumTime_s seconds" \
     | tee -a result_log/rk_alsa_noise_result.log
