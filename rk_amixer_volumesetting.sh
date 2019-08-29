#! /bin/sh
# 
# Copyright (C) 2011 Texas Instruments Incorporated - http://www.ti.com/
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
# @desc Varies the volume by playing the audio in backgroung using amixer interface.
# @params  none.
# @history 2011-04-07: First version
# @history 2011-05-13: Removed st_log.sh
source "common.sh"  # Import do_cmd(), die() and other functions

############################# Functions #######################################
usage()
{
	cat <<-EOF >&2
	usage: ./${0##*/} [-D <device> ]
  -D audio device to use during the test, i.e hw:1,0, defaults to hw:0,0
	EOF
	exit 0
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

: ${DEVICE:=$(get_audio_devnodes.sh -d aic -t play | grep 'hw:[0-9]' || echo 'hw:0,0')}
CARD=$(echo "${DEVICE}" | cut -c 4)

############################ USER-DEFINED Params ###############################
# Try to avoid defining values here, instead see if possible
# to determine the value dynamically. ARCH, DRIVER, SOC and MACHINE are 
# initilized and exported by runltp script based on platform option (-P)
case $ARCH in
esac
case $DRIVER in
esac
case $SOC in
esac
case $MACHINE in
*dra7xx-evm|am57xx-evm|k2g-evm)
		CAPTURE_NAME="PGA Capture Volume";
		PLAYBACK_NAME="PCM Playback Volume"
		MINVAL=0
		MAXVAL=127
		STEP=30
		;;
am180x-evm|dm355-evm|dm365-evm|dm6446-evm|dm6467-evm|dm368-evm)
		CAPTURE_NAME="PGA Capture Volume";
		PLAYBACK_NAME="PCM Playback Volume"
		MINVAL=0
		MAXVAL=127
		STEP=30
		;;
omap3evm)
		CAPTURE_NAME="Analog Capture Volume";
		PLAYBACK_NAME="Headset Playback Volume"
		MINVAL=0
		MAXVAL=5
		STEP=1
		amixer cset numid=25 1,1
		amixer cset numid=28 1,1		
		;;		
am37x-evm|beagleboard)		
		CAPTURE_NAME="Analog Capture Volume";
		PLAYBACK_NAME="Headset Playback Volume"
		MINVAL=0
		MAXVAL=5
		STEP=1
		;;
am3517-evm)		
		CAPTURE_NAME="Line Input Volume";
		PLAYBACK_NAME="Line Output Volume"
		MINVAL=0
		MAXVAL=31
		STEP=5
		;;
da850-omapl138-evm)
                CAPTURE_NAME="PGA Capture Volume";
                PLAYBACK_NAME="PCM Playback Volume"
                MINVAL=0
                MAXVAL=127
                STEP=30
                ;;
am387x-evm|am389x-evm|am335x-evm|dm385-evm|am43xx-gpevm)
                CAPTURE_NAME="PGA Capture Volume";
                PLAYBACK_NAME="PCM Playback Volume"
                MINVAL=0
                MAXVAL=127
                STEP=30
                ;;
am43xx-epos)
                CAPTURE_NAME="ADC Capture Volume";
                PLAYBACK_NAME="DAC Playback Volume"
                MINVAL=0
                MAXVAL=175
                STEP=30
                ;;
esac



########################### REUSABLE TEST LOGIC ###############################

amixer -c ${CARD} controls
amixer -c ${CARD} contents
arecord -D ${DEVICE} -f dat -d 1000 | aplay -D {DEVICE} -f dat -d 1000&
do_cmd amixer -c ${CARD} cset name=\'$PLAYBACK_NAME\' $PLYMAXVAL,$PLYMAXVAL
sleep 15

i=$MINVAL
j=$MINVAL
while [[ $i -lt $MAXVAL ]]
do
	j=$MINVAL
	while [[ $j -lt $MAXVAL ]]
	do
		do_cmd amixer -c ${CARD} cset name=\'$PLAYBACK_NAME\' $i,$j
		sleep 15
		let "j += $STEP"
	done	
	let "i += $STEP"
	sleep 15

done

i=$MINVAL
j=$MINVAL
while [[ $i -lt $MAXVAL ]]
do
	j=$MINVAL
	while [[ $j -lt $MAXVAL ]]
	do
		do_cmd amixer -c ${CARD} cset name=\'$CAPTURE_NAME\' $i,$j
		sleep 15		
		let "j += $STEP"
	done	
	let "i += $STEP"
	sleep 15

done


