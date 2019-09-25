#!/bin/bash
#
# Copyright (C) 2011 Texas Instruments Incorporated - http://www.ti.com/
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

# @Request: Need to be in the same path as the rk_alsa_test_tool.sh
# @desc Test internal loopback, prohibit external loopback, 
#	otherwise it will cause howling.
#	Need manual monitoring.

#record time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result"
echo "$startTime" > rk_alsa_loopback_result.log

#features passes vs. features all
feature_pass=0
feature_cnt=0
feature_all=0

feature_test () 
{
	echo "============================================"
	echo -e "\n$feature_cnt:|LOG| CMD=$*" \
		| tee -a rk_alsa_loopback_result.log
	echo "-------------------------------------------"
	eval $* >tmp.log 2>&1
	eval_result=`echo "$?"`
	cat tmp.log
	evaluate_result $eval_result
}
evaluate_result () 
{
	underrun_num=`cat tmp.log | grep -o -i Underrun | wc -l`
        overrun_num=`cat tmp.log | grep -o -i Overrun | wc -l`
	if [[ $underrun_num != 0 ]] || [[ $overrun_num != 0 ]];then
		echo "$feature_cnt:|LOG| Underrun num is $underrun_num" \
				| tee -a rk_alsa_loopback_result.log
		echo "$feature_cnt:|LOG| Overrun num is $overrun_num" \
				| tee -a rk_alsa_loopback_result.log
	fi

	#Determine if buffer_size is automatically converted
	buffer_size_actual=`cat tmp.log | grep buffer_size | cut -d ':' -f 2 | cut -d ' ' -f 2` 
	period_size_actual=`cat tmp.log | grep period_size | cut -d ':' -f 2 | cut -d ' ' -f 2` 
	if [ "$buffer_size_actual" != "${TEST_BUFFER_SIZE[$i]}" ] \
				&& [[ $buffer_size_actual != '' ]] \
				 && [[ ${TEST_BUFFER_SIZE[$i]} != '' ]];then
		echo "$feature_cnt:|FAIL| Return code is $1 ." \
		     "Fail buffer size is ${TEST_BUFFER_SIZE[$i]}" \
		     | tee -a rk_alsa_loopback_result.log
		echo "$feature_cnt:|Auto-conversion| buffer_size from" \
		     "${TEST_BUFFER_SIZE[$i]} converted to $buffer_size_actual"\
		     | tee -a rk_alsa_loopback_result.log

	#Determine if period_size is automatically converted
	elif [[ $period_size_actual != ${TEST_PERIOD_SIZE[$i]} ]] \
				&& [[ $period_size_actual -ne '' ]] \
				 && [[ ${TEST_PERIOD_SIZE[$i]} -ne '' ]];then
		echo "$feature_cnt:|FAIL| Return code is $1 ." \
		     "Fail period size is ${TEST_PERIOD_SIZE[$i]}" \
		     | tee -a rk_alsa_loopback_result.log
		echo "$feature_cnt:|Auto-conversion| period_size from" \
		     "${TEST_PERIOD_SIZE[$i]} converted to $period_size_actual"\
		     | tee -a rk_alsa_loopback_result.log

	#Normal judgment
	else
		if [ $1 -eq 0 ]; then
			feature_pass=$((feature_pass+1))
			echo "$feature_cnt:|PASS| The test passed successfully"\
			     | tee -a rk_alsa_loopback_result.log
		else
			echo "$feature_cnt:|FAIL| Return code is $1 ." \
			     | tee -a rk_alsa_loopback_result.log
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
CHANNELS=`echo "$CAP_STRING" | grep -w CHANNELS | cut -d ':' -f 2`
echo "HW_CHANNELS is $CHANNELS"


#capture/playback test.
#The test result can be given automatically, 
#but it is only judged whether the capture/playback
#is successful under the setting.

#================================alsa_accesstype================================
feature_test bash rk_alsa_test_tool.sh -t loopback -a 0 #RW_INTERLEAVED
feature_test bash rk_alsa_test_tool.sh -t loopback -a 1 #MMAP_INTERLEAVED
feature_test bash rk_alsa_test_tool.sh -t loopback -a 2 #RW_NONINTERLEAVED
feature_test bash rk_alsa_test_tool.sh -t loopback -a 3 #MMAP_NONINTERLEAVED

#================================alsa_opmode====================================
feature_test bash rk_alsa_test_tool.sh -t loopback -o 0 #Blocking 
feature_test bash rk_alsa_test_tool.sh -t loopback -o 1 #Non-Blocking 

#================================alsa_buffersize================================
TEST_BUFFER_SIZE=(16 32 64 128 256 512 1024 2048 4096 \
                  8192 16384 32768 65536 131072 262144 524288 1048576) #2^20
i=0
while [[ TEST_BUFFER_SIZE[$i] -ne '' ]]
do
	feature_test bash rk_alsa_test_tool.sh -t loopback \
						-b ${TEST_BUFFER_SIZE[$i]} -v 1
	let "i += 1"
done
TEST_BUFFER_SIZE=() #Empty, easy to judge in the evaluate_result()
#================================alsa_periodsize================================
# @name Testing for various period sizes
# @desc Do capture, playback and loopback for various period sizes
TEST_PERIOD_SIZE=(16 32 64 128 256 512 1024 2048 4096 \
                   8192 16384 32768 65536 131072 262144 524288 1048576) #2^20
i=0
while [[ TEST_PERIOD_SIZE[$i] -ne '' ]]
do
        feature_test bash rk_alsa_test_tool.sh -t loopback \
						-p ${TEST_PERIOD_SIZE[$i]} -v 1
	let "i += 1"
done
TEST_PERIOD_SIZE=() #Empty, easy to judge in the evaluate_result()
#================================alsa_channels==================================
feature_test bash rk_alsa_test_tool.sh -t loopback -c 1
feature_test bash rk_alsa_test_tool.sh -t loopback -c 2

#================================alsa_samplerate================================
TEST_SAMPLERATE=(8000 11025 16000 22050 24000 32000 44100 48000 88200 96000)
i=0
while [[ TEST_SAMPLERATE[$i] -ne '' ]]
do      
        feature_test bash rk_alsa_test_tool.sh -t loopback -r ${TEST_SAMPLERATE[$i]}
	let "i += 1"
done
#alsa_higher_samplerate
feature_test bash rk_alsa_test_tool.sh -t loopback -r 192000 -d 10

#================================alsa_sampleformat==============================
#arecord wave header support format
TEST_FORMAT=(U8 S16_LE S32_LE FLOAT_LE S24_LE S24_3LE)
i=0
while [[ -n ${TEST_FORMAT[$i]} ]]
do
        feature_test bash rk_alsa_test_tool.sh -t loopback -f ${TEST_FORMAT[$i]}
	let "i += 1"
done


#echo all test result 
echo "[$feature_pass/$feature_cnt] features passes." \
				| tee -a rk_alsa_loopback_result.log

#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:" \
     "$sumTime_m minutes and $sumTime_s seconds" \
     | tee -a rk_alsa_loopback_result.log
