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

############################# Functions ########################################
usage()
{
	cat <<-EOF >&2
	usage: bash ${0##*/} [-a] [-b] [-c] [-f] [-l] [-m] [-n] [-o] [-p] [-s] [-h]

     -a  	   Test access
     -b            Test buffer size
     -c            Test channels
     -f            Test format
     -l            Test latency
     -m            Test power management
     -n            Test nosie
     -o            Test operation mode
     -p            Test period size
     -s            Test sample rate
     -h            Help
	EOF
	exit 0
}

feature_test () 
{
	echo "============================================"
	echo -e "\n|LOG| CMD=bash rk_alsa_$*.sh > running_log/$*_running.log 2>&1" 
	bash rk_alsa_$*.sh > running_log/$*_running.log 2>&1
	tail -n 2 running_log/$*_running.log #show the last two lines of the log
}
################################ CLI Params ####################################
# Please use getopts
while getopts abcflnopmsh arg
do case $arg in
        a)	ACCESS="access" ;;
        b)	BUFFER_SIZE="buffer_size";;        
        c)	CHANNELS="channels";;        
        f)	FORMAT="format";;        
        l)	LATENCY="latency";;      
        m)	PM="pm";;           
        n)	NOISE="noise";;                                
        o)	OPMODE="opmode";;                                
        p)	PERIOD_SIZE="period_size";;                                          
        s)	SAMPLE_RATE="sample_rate";;                                       
        h)	usage;;
        \?)	echo "Invalid Option -$OPTARG ";exit 1;; 
esac
done

if (($# == 0));then
	echo "No parameters are specified, all scripts are tested by default"
	ACCESS="access";BUFFER_SIZE="buffer_size";CHANNELS="channels";\
     FORMAT="format";LATENCY="latency";NOISE="noise";OPMODE="opmode";\
     PERIOD_SIZE="period_size";PM="pm";SAMPLE_RATE="sample_rate";
fi

TEST_SCRIPTS=($ACCESS $BUFFER_SIZE $CHANNELS $FORMAT $LATENCY $NOISE $OPMODE \
              $PERIOD_SIZE $PM $SAMPLE_RATE)

#record result and time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
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

echo "==================AUDIO DEV INFO=================="
aplay -l
arecord -l
echo "==================CAPTURE HW PARAMS=================="
echo "$ARECORD_CAP_STRING"
echo "==================PLAYBACK HW PARAMS=================="
echo "$APLAY_CAP_STRING"


echo "==================RK ALSA TESTS RESULT=================="
mkdir -p running_log
mkdir -p result_log
mkdir -p tmp_snd

echo "TEST_SCRIPTS is ${TEST_SCRIPTS[@]}"
i=0
while [[ $i -lt ${#TEST_SCRIPTS[@]} ]]
do      
	feature_test ${TEST_SCRIPTS[$i]}
	let "i += 1"
done

#Consolidate test result log
echo "all tests result log" > rk_alsa_tests_result.log
i=0
while [[ $i -lt ${#TEST_SCRIPTS[@]} ]]
do      
	echo "======${TEST_SCRIPTS[$i]}======" >> rk_alsa_tests_result.log
	cat result_log/rk_alsa_${TEST_SCRIPTS[$i]}_result.log >> rk_alsa_tests_result.log
	let "i += 1"
done
echo "all tests result log in rk_alsa_tests_result.log" \
	| tee -a rk_alsa_tests_result.log

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
     "$sumTime_m minutes and $sumTime_s seconds" \
	| tee -a rk_alsa_tests_result.log