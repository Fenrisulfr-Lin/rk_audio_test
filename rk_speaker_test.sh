#!/bin/bash
################################################################################ 
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
#
# @desc Run speaker-test utility with all available options to test sound output 

############################# Functions ########################################
usage()
{
	echo "rk_speaker_test.sh [For options (see speaker-test help)"
	echo "all other args are passed as-is to speaker-test"
	echo "speaker-test help:"
        speaker-test -h
	exit 1
}

#print log and execute cmd
do_cmd() 
{
	CMD=$*
	echo -e "\n|LOG|CMD=$CMD"
	eval $CMD
	RESULT=$?
	#If use 'exit $RESULT', 
	#then a test error occurs, subsequent tests cannot continue
	if [ $RESULT -ne 0 ];then
		echo "|FAIL|:$CMD failed. Return code is $RESULT" \
		     >> rk_speaker_test_result.log	
	fi
	if [ $RESULT -eq 0 ];then
		echo "|PASS|:$CMD passed." >> rk_speaker_test_result.log
	fi
}
################################ CLI Params ####################################
# Please use getopts
while getopts  :H:h arg
do case $arg in
        h)      usage;;
        :)      ;; 
        \?)     ;;
esac
done
################################# TEST #########################################
#record result and time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result" > rk_speaker_test_result.log
echo "$startTime" >> rk_speaker_test_result.log

echo "Starting speaker-test TEST"
TEST_LOOP=2

TEST_FORMAT=(S8 S16_LE S16_BE FLOAT_LE S32_LE S32_BE)
i=0
while [[ $i -lt 6 ]] #String cannot be judged non-empty
do	
	do_cmd speaker-test -c 2 --format ${TEST_FORMAT[$i]} -l $TEST_LOOP
	let "i += 1"
done

TEST_TYPE=(wav pink sine)
i=0
while [[ $i -lt 3 ]] #String cannot be judged non-empty
do	
	do_cmd speaker-test -c 1 -t ${TEST_TYPE[$i]} -l $TEST_LOOP
	do_cmd speaker-test -c 2 -t ${TEST_TYPE[$i]} -l $TEST_LOOP
	let "i += 1"
done

TEST_RATE=(8000 11025 16000 22050 24000 32000 44100 48000 88200 96000 192000)
i=0
while [[ TEST_RATE[$i] -ne '' ]]
do
	do_cmd speaker-test -c 2 -r ${TEST_RATE[$i]} -l $TEST_LOOP
	let "i += 1"
done

TEST_PERIOD=(1 2 4 8 16 32 64 128 256 512 1024 2046 4096 8192 16384 32768)
i=0
while [[ TEST_PERIOD[$i] -ne '' ]]
do
	do_cmd speaker-test -c 2 --period ${TEST_PERIOD[$i]} -l $TEST_LOOP
	let "i += 1"
done

TEST_BUFFER=(64 512 4096 32768 65536)
i=0
while [[ TEST_BUFFER[$i] -ne '' ]]
do
	do_cmd speaker-test -c 2 --buffer ${TEST_BUFFER[$i]} -l $TEST_LOOP
	let "i += 1"
done


#echo total running time
endTime=`date +%Y%m%d-%H:%M`
endTime_s=`date +%s`
sumTime_s=$[ $endTime_s - $startTime_s ]
sumTime_m=$[ $sumTime_s / 60 ]
sumTime_s=$[ $sumTime_s - $sumTime_m * 60 ] 

echo "$startTime ---> $endTime" \
     "Total running time:$sumTime_m minutes and $sumTime_s seconds" \
     >> rk_speaker_test_result.log