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
echo "rk_alsa_tests_result" > rk_alsa_tests_result.log
echo "$startTime" >> rk_alsa_tests_result.log

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

bash rk_alsa_sample_rate.sh > running_log/rk_alsa_sample_rate_running.log 2>&1
bash rk_alsa_format.sh      > running_log/rk_alsa_format_running.log      2>&1
bash rk_alsa_channels.sh    > running_log/rk_alsa_channels_running.log    2>&1
bash rk_alsa_opmode.sh      > running_log/rk_alsa_opmode_running.log      2>&1
bash rK_alsa_access.sh      > running_log/rK_alsa_access_running.log      2>&1
bash rk_alsa_period_size.sh > running_log/rk_alsa_period_size_running.log 2>&1
bash rk_alsa_buffer_size.sh > running_log/rk_alsa_buffer_size_running.log 2>&1
bash rk_alsa_noise.sh       > running_log/rk_alsa_noise_running.log       2>&1
bash rk_alsa_latency.sh     > running_log/rk_alsa_latency_running.log     2>&1
bash rk_alsa_pm.sh          > running_log/rk_alsa_pm_running.log          2>&1

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
     "$sumTime_m minutes and $sumTime_s seconds" >> rk_alsa_tests_result.log