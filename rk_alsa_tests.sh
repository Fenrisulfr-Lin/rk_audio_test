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

# @desc Call other scripts for a overall test.

#record result and time
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

ARECORD_CAP_STRING=`arecord -D $REC_DEVICE --dump-hw-params -d 1 /dev/zero 2>&1`
APLAY_CAP_STRING=`aplay -D $PLAY_DEVICE --dump-hw-params -d 1 /dev/zero 2>&1`

echo " ==================AUDIO DEV INFO=================="
aplay -l
arecord -l
echo " ==================CAPTURE HW PARAMS=================="
echo "$ARECORD_CAP_STRING"
echo " ==================PLAYBACK HW PARAMS=================="
echo "$APLAY_CAP_STRING"


feature_test () 
{
	echo "============================================"
	echo -e "\n|LOG| CMD=bash $*.sh > running_log/$*_running.log 2>&1" 
	bash $*.sh > running_log/$*_running.log 2>&1
     tail -n 2 running_log/$*_running.log #show the last two lines of the log
}

mkdir -p running_log
mkdir -p result_log

#in alphabetical order
TEST_SCRIPTS=(rk_alsa_access rk_alsa_buffer_size rk_alsa_channels \
               rk_alsa_format rk_alsa_latency rk_alsa_noise rk_alsa_opmode \
               rk_alsa_period_size rk_alsa_pm rk_alsa_sample_rate)
i=0
while [[ -n ${TEST_SCRIPTS[$i]} ]]
do      
	feature_test ${TEST_SCRIPTS[$i]}
	let "i += 1"
done


#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_h=$[ $sumTime_m / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 
sumTime_m=$[ $sumTime_m - $sumTime_h * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:$sumTime_h hours," \
     "$sumTime_m minutes and $sumTime_s seconds"