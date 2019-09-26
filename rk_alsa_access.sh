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
# @desc test the audio with Non-Interleaved access or mmap access.
#       Access Type   : Access Type (0->RW_INTERLEAVED,1->MMAP_INTERLEAVED)
#				   (2->RW_NONINTERLEAVED,3->MMAP_NONINTERLEAVED)

#record time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result"
mkdir -p result_log
echo "$startTime" > result_log/rk_alsa_access_result.log

#features passes vs. features all
feature_pass=0
feature_cnt=0
feature_all=0

feature_test () 
{
	echo "============================================"
	echo -e "\n$feature_cnt:|LOG| CMD=$*" 
	echo "-------------------------------------------"
	eval $*
	evaluate_result $?
}
evaluate_result () 
{
        if [ $1 -eq 0 ]; then
                feature_pass=$((feature_pass+1))
                echo "$feature_cnt:|PASS| The test passed successfully"
                echo "alsa_${TEST_TYPE[$j]}_access_${TEST_ACCESS[$i]}:" "pass" \
                | tee -a result_log/rk_alsa_access_result.log
        else
                echo "$feature_cnt:|FAIL| Return code is $1." \
                "Fail access is ${TEST_ACCESS[$i]}" 
                echo "alsa_${TEST_TYPE[$j]}_access_${TEST_ACCESS[$i]}:" "fail" \
                | tee -a result_log/rk_alsa_access_result.log
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
ACCESS_RANGE=`echo "$CAP_STRING" | grep -w ACCESS | tr -s " "`
echo "HW_ACCESS_RANGE is $ACCESS_RANGE"

ACCESS_RANGE_VALUE=`echo "$ACCESS_RANGE" | tr -s " " | cut -d " " -f 2-`
TEST_ACCESS=($ACCESS_RANGE_VALUE)
echo "TEST ACCESS is ${TEST_ACCESS[@]}"


#capture/playback test.
#The test result can be given automatically, 
#but it is only judged whether the capture/playback
#is successful under the setting.
i=0
TEST_TYPE=(capture playback)
while [[ -n ${TEST_ACCESS[$i]} ]]
do
        case ${TEST_ACCESS[$i]} in
        "RW_INTERLEAVED") 
                j=0
                while [[ -n ${TEST_TYPE[$j]} ]]
                do
                feature_test bash rk_alsa_test_tool.sh -t ${TEST_TYPE[$j]} -a 0\
                     -F ALSA_ACCESSTYPE_${TEST_ACCESS[$i]}.snd;
                let "j += 1"
                done;;
        "MMAP_INTERLEAVED")
                j=0
                while [[ -n ${TEST_TYPE[$j]} ]]
                do
                feature_test bash rk_alsa_test_tool.sh -t ${TEST_TYPE[$j]} -a 1\
                     -F ALSA_ACCESSTYPE_${TEST_ACCESS[$i]}.snd;
                let "j += 1"
                done;;
        "RW_NONINTERLEAVED") 
                j=0
                while [[ -n ${TEST_TYPE[$j]} ]]
                do
                feature_test bash rk_alsa_test_tool.sh -t ${TEST_TYPE[$j]} -a 2\
                     -F ALSA_ACCESSTYPE_${TEST_ACCESS[$i]}.snd;
                let "j += 1"
                done;;
        "MMAP_NONINTERLEAVED")
                j=0
                while [[ -n ${TEST_TYPE[$j]} ]]
                do
                feature_test bash rk_alsa_test_tool.sh -t ${TEST_TYPE[$j]} -a 3\
                     -F ALSA_ACCESSTYPE_${TEST_ACCESS[$i]}.snd;
                let "j += 1"
                done;;
        esac
        let "i += 1"
done


echo "[$feature_pass/$feature_cnt] features passes." \
				| tee -a result_log/rk_alsa_access_result.log

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:" \
     "$sumTime_m minutes and $sumTime_s seconds" \
     | tee -a result_log/rk_alsa_access_result.log