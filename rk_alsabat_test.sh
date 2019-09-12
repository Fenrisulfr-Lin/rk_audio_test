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
#           10) configurable duration: in samples
#           11) configurable duration: in seconds
#           12) configurable data format: U8
#           13) configurable data format: S16_LE
#           14) configurable data format: S24_3LE
#           15) configurable data format: S32_LE
#           16) configurable data format: cd
#           17) configurable data format: dat
#           18) standalone mode: play and capture
#           19) local mode: analyze local file
#           20) round trip latency test
#           21) noise detect threshold in SNR(dB)
#           22) noise detect threshold in noise percentage(%)
#           23) power management: S3 test

#record result and time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "start time:$startTime" 

# default devices ,default value is plughw:0,0

play_device="default" 
rec_device="default"

bin="alsabat"
commands="$bin -P $play_device -C $rec_device"

file_sin_mono="default_mono.wav"
file_sin_dual="default_dual.wav"
logdir="log_rk_alsabat_test"

# frequency range of signal
maxfreq=16547
minfreq=17

# sleep time and pause time
sleep_time=5
pause_time=2

evaluate_result () 
{
	feature_cnt=$((feature_cnt+1))
	if [ $1 -eq 0 ]; then
		feature_pass=$((feature_pass+1))
		echo "pass"
	else
		echo "fail"
	fi
}

feature_test () 
{
	echo "============================================"
	echo "$feature_cnt: ALSA $2"
	echo "-------------------------------------------"
	echo "$commands $1 --log=$logdir/$feature_cnt.log"
	$commands $1 --log=$logdir/$feature_cnt.log
	evaluate_result $?
	echo "$commands $1" >> $logdir/$((feature_cnt-1)).log
}

feature_test_power () 
{
	echo "============================================"
	echo "$feature_cnt: ALSA $2"
	echo "-------------------------------------------"
	echo "$commands $1 --log=$logdir/$feature_cnt.log"

	# run alsabat in the background
	nohup $commands $1 > $logdir/$feature_cnt.log 2>&1 &
	sleep $pause_time
	pid=`ps -aux |grep alsabat|head -1 |awk -F ' ' '{print $2}'`

	# stop the alsabat thread
	kill -STOP $pid > /dev/null
	sleep 4

	# do system S3
	rtcwake -m mem -s $sleep_time
	sleep $pause_time

	# resume the alasbat thread to run
	kill -CONT $pid > /dev/null

	# wait for alsabat to complete the analysis
	sleep $pause_time
	cat $logdir/$feature_cnt.log |grep -i "Return value is 0" > /dev/null
	evaluate_result $?
	echo "$commands $1" >> $logdir/$((feature_cnt-1)).log
}

echo "*******************************************"
echo "             rk alsabat test               "
echo "-------------------------------------------"

# get device
echo "usage:"
echo "  bash $0 <sound card> "
echo "  bash $0 <device-playback> <device-capture>"
echo "  like bash $0 plughw:0,0 plughw:0,0 "

if [ $# -eq 2 ]; then
	play_device=$1
	rec_device=$2
elif [ $# -eq 1 ]; then
	play_device=$1
	rec_device=$1
fi

echo "current setting:"
echo "bash $0 $play_device $rec_device"

# run test
mkdir -p $logdir

#features passes vs. features all
feature_pass=0
feature_cnt=0
feature_all=0
sigma_k=30.0

#0
feature_test "-c1 --saveplay $file_sin_mono -k $sigma_k" \
		"generate mono wav file with default params"
feature_test "-c2 --saveplay $file_sin_dual -k $sigma_k" \
		"generate dual wav file with default params"
sleep 5
feature_test "-P $play_device" "single line mode, playback"
feature_test "-C $rec_device --standalone" "single line mode, capture"

feature_test "--file $file_sin_mono -k $sigma_k" "play mono wav file and detect"
feature_test "--file $file_sin_dual -k $sigma_k" "play dual wav file and detect"
feature_test "-c1 -k $sigma_k" "configurable channel number: 1"
feature_test "-c2 -F $minfreq:$maxfreq -k $sigma_k" \
	     "configurable channel number: 2"
feature_test "-r44100 -k $sigma_k" "configurable sample rate: 44100"
#10
feature_test "-r48000 -k $sigma_k" "configurable sample rate: 48000"
feature_test "-n10000 -k $sigma_k" "configurable duration: in samples"
feature_test "-n2.5s -k $sigma_k" "configurable duration: in seconds"

feature_test "-f U8 -k $sigma_k" "configurable data format: U8"
feature_test "-f S16_LE -k $sigma_k" "configurable data format: S16_LE"
feature_test "-f S24_3LE -k $sigma_k" "configurable data format: S24_3LE"
feature_test "-f S32_LE -k $sigma_k" "configurable data format: S32_LE"
feature_test "-f cd -k $sigma_k" "configurable data format: cd"
feature_test "-f dat -k $sigma_k" "configurable data format: dat"

feature_test "--standalone" "standalone mode: play and capture"
#the latest file generated by alsabat
latestfile=`ls -t1 /tmp/bat.wav.* | head -n 1` 
feature_test "--local -F $maxfreq --file $latestfile -k $sigma_k" \
	     "local mode: analyze local file"
#20
feature_test "--roundtriplatency" "round trip latency test"
feature_test "--snr-db 26 -k $sigma_k" "noise detect threshold in SNR(dB)"
feature_test "--snr-pc 5 -k $sigma_k" \
	     "noise detect threshold in noise percentage(%)"
feature_test_power "-n5s -k $sigma_k" "power management: S3 test"

echo "[$feature_pass/$feature_cnt] features passes."

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time: $sumTime_m minutes and $sumTime_s seconds"