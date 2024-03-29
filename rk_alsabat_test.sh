#!/bin/bash
#
# Copyright (C) 2013-2016 Intel Corporation
# Copyright (C) 2019 Fuzhou Rockchip Electronics Co.,Ltd
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# @desc Use the alsabat tool to perform various tests
# @features 0) generate mono wav file with default params
#	    1) generate dual wav file with default params
#           2) single line mode, playback
#           3) single line mode, capture
#           4) play mono wav file and detect
#           5) play dual wav file and detect
#           6) configurable channel number: 1
#           7) configurable channel number: 2
#           8) configurable sample rate: 44100
#           9) configurable sample rate: 48000
#           10) configurable duration: in 10000 frames
#           11) configurable duration: in 2.5 seconds
#           12) configurable data format: S16_LE
#           13) configurable data format: S24_3LE
#           14) configurable data format: S32_LE
#           15) configurable data format: cd
#           16) configurable data format: dat
#           17) standalone mode: play and capture
#           18) local mode: analyze local file

mkdir -p tmp_snd
mkdir -p result_log

#record result and time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "start time:$startTime" > result_log/rk_alsabat_test_result.log

# default devices ,default value is hw:0,0
CAPTURE_SOUND_CARDS=( $(arecord -l | grep -i card | grep -o '[0-9]\+:' | \
						cut -c 1 | awk 'FNR==1') )
CAPTURE_SOUND_DEVICE=($(arecord -l | grep -i card | grep -o '[0-9]\+:' | \
						cut -c 1 | awk 'FNR==2') )
: ${REC_DEVICE:=$(echo "hw:${CAPTURE_SOUND_CARDS},${CAPTURE_SOUND_DEVICE}" |\
		  			 grep 'hw:[0-9]' || echo 'hw:0,0')}

PLAYBACK_SOUND_CARDS=( $(aplay -l | grep -i card | grep -o '[0-9]\+:' | \
						cut -c 1 | awk 'FNR==1') )
PLAYBACK_SOUND_DEVICE=($(aplay -l | grep -i card | grep -o '[0-9]\+:' | \
			   			cut -c 1 | awk 'FNR==2') )
: ${PLAY_DEVICE:=$(echo "hw:${PLAYBACK_SOUND_CARDS},${PLAYBACK_SOUND_DEVICE}" |\
					 grep 'hw:[0-9]' || echo 'hw:0,0')}

CAP_STRING=`aplay -D $PLAY_DEVICE --dump-hw-params -d 1 /dev/zero 2>&1`
CHANNELS=`echo "$CAP_STRING" | grep -w CHANNELS | cut -d ':' -f 2`
echo "HW_CHANNELS is $CHANNELS"

play_device=$PLAY_DEVICE 
rec_device=$REC_DEVICE


bin="alsabat"
commands="$bin -P $play_device -C $rec_device"


file_sin_mono="tmp_snd/default_mono.wav"
file_sin_dual="tmp_snd/default_dual.wav"
logdir="rk_alsabat_test_log"

# frequency range of signal
maxfreq=16547
minfreq=17

evaluate_result () 
{
	feature_cnt=$((feature_cnt+1))
	if [ $1 -eq 0 ]; then
		feature_pass=$((feature_pass+1))
		echo "$2:" "pass" \
			| tee -a result_log/rk_alsabat_test_result.log
	else
		echo "$2:" "fail" \
			| tee -a result_log/rk_alsabat_test_result.log
	fi
}

feature_test () 
{
	echo "============================================"
	echo "$feature_cnt: ALSA $2"
	echo "-------------------------------------------"
	echo "$commands $1 --log=$logdir/$feature_cnt.log"
	$commands $1 --log=$logdir/$feature_cnt.log
	evaluate_result $? $2
	echo "$commands $1" >> $logdir/$((feature_cnt-1)).log
}

echo "*******************************************"
echo "             rk alsabat test               "
echo "-------------------------------------------"

# get device
echo "usage:"
echo "  bash $0 <sound card> "
echo "  bash $0 <device-playback> <device-capture>"
echo "  like bash $0 hw:0,0 hw:0,0 "
if [ $# -eq 2 ]; then
	play_device=$1
	rec_device=$2
elif [ $# -eq 1 ]; then
	play_device=$1
	rec_device=$1
fi
#If there is input, need to assign value to the command again.
commands="$bin -P $play_device -C $rec_device"

echo "|LOG| current setting:"
echo "|LOG| CMD=bash $0 $play_device $rec_device"

# run test
mkdir -p $logdir

#features passes vs. features all
feature_pass=0
feature_cnt=0
feature_all=0

#Frequency detection threshold
sigma_k=30.0

#0
feature_test "-c1 --saveplay $file_sin_mono -k $sigma_k" \
		"generate_mono_wav_file_with_default_params"
feature_test "-c2 --saveplay $file_sin_dual -k $sigma_k" \
		"generate_dual_wav_file_with_default_params"
sleep 5
feature_test "-P $play_device -c $CHANNELS" "single_line_mode_playback"
feature_test "-C $rec_device --standalone -c $CHANNELS" \
		"single_line_mode_capture"
feature_test "--file $file_sin_mono -k $sigma_k -c 1" \
		"play_mono_wav_file_and_detect"
#5
feature_test "--file $file_sin_dual -k $sigma_k -c 2" \
		"play_dual_wav_file_and_detect"
feature_test "-c1 -k $sigma_k" "configurable_channel_number_1"

feature_test "-c2 -F $minfreq:$maxfreq -k $sigma_k" \
	     "configurable_channel_number_2"
echo "configurable_channel_number_2: Require separate testing of left and right channels" \
			| tee -a result_log/rk_alsabat_test_result.log

feature_test "-r44100 -k $sigma_k -c $CHANNELS" \
		"configurable_sample_rate_44100"
feature_test "-r48000 -k $sigma_k -c $CHANNELS" \
		"configurable_sample_rate_48000"

sleep 10 #Avoid calling too fast, causing file generation errors
#10
feature_test "-n10000 -k $sigma_k -c $CHANNELS" \
		"configurable_duration_in_10000_frames"
feature_test "-n2.5s -k $sigma_k -c $CHANNELS" \
		"configurable_duration_in_2.5_seconds"

feature_test "-f S16_LE -k $sigma_k -c $CHANNELS" \
		"configurable_data_format_S16_LE"
feature_test "-f S24_3LE -k $sigma_k -c $CHANNELS" \
		"configurable_data_format_S24_3LE"
feature_test "-f S32_LE -k $sigma_k -c $CHANNELS" \
		"configurable_data_format_S32_LE"
#15
feature_test "-f cd -k $sigma_k -c $CHANNELS" "configurable_data_format_cd"
feature_test "-f dat -k $sigma_k -c $CHANNELS" "configurable_data_format_dat"

feature_test "--standalone -c $CHANNELS" "standalone_mode_play_and_capture"
#18 The latest file generated by alsabat.For the 20th test
latestfile=`ls -t1 /tmp/bat.wav.* | head -n 1` 
feature_test "--local -F 997 --file $latestfile -k $sigma_k" \
	     "local_mode_analyze_local_file"


echo "[$feature_pass/$feature_cnt] features passes." \
			| tee -a result_log/rk_alsabat_test_result.log

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time: $sumTime_m minutes and $sumTime_s seconds" \
			| tee -a result_log/rk_alsabat_test_result.log