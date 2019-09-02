#! /bin/bash
############################################################################### 
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

############################# Functions #######################################
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
	if [ $RESULT -ne 0 ];then
		echo "|FAIL|:$CMD failed. Return code is $RESULT"
		exit $RESULT
	fi
	if [ $RESULT -eq 0 ];then
		echo "|PASS|:$CMD passed."
	fi
}
################################ CLI Params ###################################
# Please use getopts
while getopts  :H:h arg
do case $arg in
        h)      usage;;
        :)      ;; 
        \?)     ;;
esac
done
########################### TEST ##############################################
echo "Starting speaker-test TEST"
TEST_LOOP=5

TEST_FORMAT=(S16_LE S16_BE FLOAT_LE S32_LE S32_BE)
i=0
while [[ $i -lt 5 ]] #String cannot be judged non-empty
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

TEST_RATE=(8000 11025 16000 22050 24000 32000 44100 48000 88200 96000)
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
	do_cmd speaker-test -c 2 --period ${TEST_BUFFER[$i]} -l $TEST_LOOP
	let "i += 1"
done

do_cmd speaker-test -c 2 -t wave -l 1000
