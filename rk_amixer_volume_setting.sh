#! /bin/bash
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
#
# @desc Varies the volume by playing the audio in backgroung 
#       using amixer interface.
# @params  none.

############################## Functions #######################################
usage()
{
	cat <<-EOF >&2
	usage: ./${0##*/} [-D <device> ]
  -D audio device to use during the test, i.e hw:1,0, defaults to hw:0,0
	EOF
	exit 0
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
	fi
	if [ $RESULT -eq 0 ];then
		echo "|PASS|:$CMD passed."
	fi
}

die() 
{
        echo "|ERROR|$*"
        exit 1
}
################################ CLI Params ####################################
# Please use getopts
while getopts  :h:D arg
do case $arg in       
        h)      usage;;
        D)      DEVICE="$OPTARG";;
        :)      die "$0: Must supply an argument to -$OPTARG.";; 
        \?)     die "Invalid Option -$OPTARG ";;
esac
done

#Use aplay to get information by default
PLAYBACK_SOUND_INFO="$(aplay -l | grep -i card)"
PLAYBACK_SOUND_CARDS=( $(aplay -l | grep -i card | grep -o '[0-9]\+:' | \
						cut -c 1 | awk 'FNR==1') )
PLAYBACK_SOUND_DEVICE=($(aplay -l | grep -i card | grep -o '[0-9]\+:' | \
						cut -c 1 | awk 'FNR==2') )

#If the -D parameter is not used. 
#Default test the first sound card obtained by aplay.
: ${DEVICE:=$(echo "hw:${PLAYBACK_SOUND_CARDS},${PLAYBACK_SOUND_DEVICE}" | \
					grep 'hw:[0-9]' || echo 'hw:0,0')}
CARD=$(echo "${DEVICE}" | cut -c 4)

########################### DO WORK ##########################
echo "============================Switch Infomation============================"
amixer -c ${CARD} contents | grep Volume -A3

echo "============================Sound Infomation============================="
echo -e "Sound_Info:\n$PLAYBACK_SOUND_INFO" #actually is Playback_Sound_Info
echo "Test device is $DEVICE"
echo "Test card is $CARD"

NUMBER_OF_VOLUME_OPTIONS=( $(amixer -c ${CARD} contents | grep Volume | \
						cut -d = -f 4 | wc -l) )
echo "Number of Switches is $NUMBER_OF_VOLUME_OPTIONS"

echo "===============================Start Test================================"
#Test each volume item 1+4*4=17 times, 3 seconds per test,3*17=51 seconds
TEST_TIME=$((NUMBER_OF_VOLUME_OPTIONS*51))
echo "Test time is $TEST_TIME seconds"

arecord -D ${DEVICE} -f dat -d $TEST_TIME | aplay -D ${DEVICE} \
					-f dat -d $TEST_TIME &
sleep 3 # There is a delay in calling the audio device

#Test different volume items
i=0
while [[ $i -lt $NUMBER_OF_VOLUME_OPTIONS ]]
do	
	VOLUME_SWITCH_NAME="$(amixer -c ${CARD} controls | grep Volume | \
					cut -d = -f 4 | awk 'FNR=='$i+1'')"
	echo "======================$VOLUME_SWITCH_NAME Test==================="

	#The default minimum value is 0, 
	#and the left and right channel volume has the same maximum value.
	VOLUME_MIN=0
	VOLUME_MAX="$(amixer -c ${CARD} contents | grep Volume -A3 | \
		grep max | cut -d = -f 6 | cut -d , -f 1 | awk 'FNR=='$i+1'')"

	#Test step size, the volume is adjusted each time by this step
	STEP=$[$VOLUME_MAX/3] 
	echo "The maximum volume is $VOLUME_MAX," \
	     "the minimum value is $VOLUME_MIN,test step is $STEP"

	#Set the maximum value before changing the volume test
	do_cmd amixer -c ${CARD} \
	       cset name=$VOLUME_SWITCH_NAME $VOLUME_MAX,$VOLUME_MAX
	sleep 3

	#Change the left channel volume after looping the right channel volume
	j=$VOLUME_MIN
	while [[ $j -le $VOLUME_MAX ]]
	do
		#Keep left channel volume unchanged,change right channel volume
		k=$VOLUME_MIN
		while [[ $k -le $VOLUME_MAX ]]
		do
			do_cmd amixer -c ${CARD} \
			       cset name=$VOLUME_SWITCH_NAME $j,$k
			sleep 3
			let "k += $STEP"
		done
		let "j += $STEP"
	done
	let "i += 1"
done
