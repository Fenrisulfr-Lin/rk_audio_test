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
# 
# @desc Toggles the switch by playing the audio in backgroung using amixer.
# @params  l) TEST_LOOP    test loop for switch toggling. default is 1.
#          D) <device>     audio device to use during the test,default is hw:0,0

############################# Functions ########################################
usage()
{
        cat <<-EOF >&2
	usage: bash ${0##*/} [-l TEST_LOOP]  [-D <device> ]
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
while getopts  :l:D:h arg
do case $arg in  
        l)      TEST_LOOP="$OPTARG";;
        D)      DEVICE="$OPTARG";;
        h)      usage;;
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

# Define default values 
: ${TEST_LOOP:=1}

#If the -D parameter is not used. 
#Default test the first sound card obtained by aplay
: ${DEVICE:="hw:${PLAYBACK_SOUND_CARDS},${PLAYBACK_SOUND_DEVICE}"}
CARD=$(echo "${DEVICE}" | cut -c 4)

################################### DO WORK ####################################

#amixer -c ${CARD} contents | grep Switch -A2 
#'amixer contents' More detailed but may not be necessary
echo "============================Switch Infomation============================"
amixer -c ${CARD} controls | grep Switch 

echo "============================Sound Infomation============================="
echo -e "Sound_Info:\n$PLAYBACK_SOUND_INFO" #actually is Playback_Sound_Info
echo "The number of test_loop is $TEST_LOOP"
echo "Test device is $DEVICE"
echo "Test card is $CARD"

NUMBER_OF_SWITHCES=( $(amixer -c ${CARD} controls | grep Switch | \
                                        cut -d = -f 4 | wc -l) )
echo "Number of Switches is $NUMBER_OF_SWITHCES"

echo "================================Start Test==============================="
#Start testing at the back without changing the switch
#Test each state(0/1) of each switch for 3 seconds,3*2=6
TEST_TIME=$((NUMBER_OF_SWITHCES*6)) 
echo "Test time is $TEST_TIME seconds"

arecord -D ${DEVICE} -f dat -d $TEST_TIME | \
        aplay -D ${DEVICE} -f dat -d $TEST_TIME &
sleep 3 # There is a delay in calling the audio device

i=0
while [[ $i -lt $TEST_LOOP ]]
do
	j=0
        while [[ $j -lt $NUMBER_OF_SWITHCES ]]
        do
                SWITCH_NAME="$(amixer -c ${CARD} controls | \
                               grep Switch | cut -d = -f 4 | \
                               awk 'FNR=='$j+1'')" #awk star from 1 not 0
                echo "====================$SWITCH_NAME Test===================="

                #Get the initial value of the switch
                SWITCH_VALUES=$(eval amixer cget name=$SWITCH_NAME | \
                                grep values=1 | cut -d , -f 3 | cut -d = -f 2)
                echo -e "|LOG|The initial value of $SWITCH_NAME"\
                        "is $SWITCH_VALUES.\n"

                #Test according to different initial values
                if [ $SWITCH_VALUES == 1 ];then
                        do_cmd amixer -c ${CARD} cset name=$SWITCH_NAME 0
                        sleep 3
                        do_cmd amixer -c ${CARD} cset name=$SWITCH_NAME 1
                        sleep 3
                fi
                if [ $SWITCH_VALUES == 0 ];then
                        do_cmd amixer -c ${CARD} cset name=$SWITCH_NAME 1
                        sleep 3
                        do_cmd amixer -c ${CARD} cset name=$SWITCH_NAME 0
                        sleep 3
                fi
                let "j += 1"
        done
	let "i += 1"	
done

