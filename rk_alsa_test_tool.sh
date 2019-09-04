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
# @desc Captures/Plays/loopbacks the audio for given parameters
# @params t) Test type     : Capture,playback,loopback
#         r) Sample rate   : Sample rate (44100,48000,88200,96000 etc)
#         f) Sample Format : Sample Format (S8,S16_LE,S24_LE,S32_LE)
#         p) Period Size   : Period Size (1,2,4,8,etc)
#         b) Buffer Size   : Buffer Size (64,512,32768,65536)
#         d) Duration      : Duration in Secs.
#         c) Channel	   : Channel.
#         F) File Name	   : File name to play from or capture to.
#         o) OpMode	   : OpMode (0->Blocking, 1->Non-Blocking)
#         a) Access Type   : Access Type (0->RW_INTERLEAVED, 1->MMAP_INTERLEAVED)
#         D) Audio Device  : Audio Device.For separate playback and capture.
#         R) Record Device : Audio Record Device.For loopback.
#         P) Playback Device : Audio PlaybackDevice.For loopback.
#         l) Capture Log   : Whether to retain captured file or delete.

############################# Functions #######################################
usage()
{
	cat <<-EOF >&2
	usage: ./${0##*/} [-t TEST_TYPE] [-D DEVICE] [-R REC_DEVICE]\
	[-P PLAY_DEVICE] [-r SAMPLE_RATE] [-f SAMPLE_FORMAT] [-p PERIOD_SIZE]\
	[-b BUFFER_SIZE] [-c CHANNEL] [-o OpMODE] [-a ACCESS_TYPE] [-d DURATION]
	-t TEST_TYPE	    Test Type. Possible Values are capture,playback,loopback.
	-D DEVICE           Device Name like hw:0,0.For separate playback and capture.
	-R REC_DEVICE       Device Name like hw:0,0.For loopback.
	-P PLAY_DEVICE      Device Name like hw:0,0.For loopback.
	-r SAMPLE_RATE	    Sample Rate like 44100,48000,88200,96000 etc.
	-f SAMPLE_FORMAT    Sample Format like S8,S16_LE,S24_LE,S32_LE.
	-p PERIOD_SIZE	    Period Size like 1,2,4,8,etc.
	-b BUFFER_SIZE	    Buffer Size like 64,512,32768,65536.
	-c CHANNEL	    Channel like 1,2.
	-F FILENAME	    File Name to capture to or playback from	
	-o OpMODE	    OpMode (0->Blocking, 1->Non-Blocking)
	-a ACCESS_TYPE	    Access Type ( 0->RW_INTERLEAVED, 1->MMAP_INTERLEAVED )
	-d DURATION         Dutaion In Secs like 5,10 etc. 
	-l CAPTURELOG_FLAG  Whether to retain captured file or delete.( 1 -> To retain, 0 -> delete )
	EOF
	exit 0
}

#Function to obtain the default value of a parameter based on the capabilities string
#  $1 capability string to parse
#  $2 parameter string to look for
#  $3 (optional), if the parameter allow a value in a range, this function returns 
#     the first value in the range, if this parameter is specified the function will
#     return the last value in the range
get_default_val()
{
  local result=`echo "$1" | grep -w "$2:" | tr -s " " | cut -d " " -f 2,3 |\
  		cut -d "[" -f 2 | cut -d "(" -f 2 | cut -d "]" -f 1 | cut -d ")" -f 1`
  local value_range=($result)
  if [ $# -gt 2 ] ; then
    echo ${value_range[${#value_range[@]} - 2]}
  else
    echo ${value_range[0]}
  fi
}

#print log and execute cmd
do_cmd() 
{
	CMD=$*
	echo -e "\n|LOG|CMD=$CMD"
	eval $CMD
	RESULT=$?
	if [ $RESULT -ne 0 ];then
		echo "|FAIL|:$CMD failed. Return code is $RESULT" >> result.log
		exit $RESULT
	fi
	if [ $RESULT -eq 0 ];then
		echo "|PASS|:$CMD passed." >> result.log
	fi
}

die() 
{
        echo "|ERROR|$*"
        exit 1
}
################################ CLI Params ###################################
# Please use getopts
while getopts  :t:r:f:F:p:b:l:d:c:o:a:D:R:P:h arg
do case $arg in
        t)      TYPE="$OPTARG";;
        r)      SAMPLERATE="$OPTARG";;        
        f)      SAMPLEFORMAT="$OPTARG";;        
        p)      PERIODSIZE="$OPTARG";;        
        b)      BUFFERSIZE="$OPTARG";;                
        d)      DURATION="$OPTARG";;                                
        c)      CHANNEL="$OPTARG";;                                
        o)      OPMODE="$OPTARG";;                                
        F)      FILE="$OPTARG";;                                        
        a)      ACCESSTYPE="$OPTARG";;                                
        D)      DEVICE="$OPTARG";;        
        R)      REC_DEVICE="$OPTARG";;        
        P)      PLAY_DEVICE="$OPTARG";;        
        l)      CAPTURELOGFLAG="$OPTARG";;                
        h)      usage;;
        :)      die "$0: Must supply an argument to -$OPTARG.";; 
        \?)     die "Invalid Option -$OPTARG ";;
esac
done

############################ Default Values for Params ########################
CAPTURE_SOUND_CARDS=( $(arecord -l | grep -i card | grep -o '[0-9]\+:' | cut -c 1 | awk 'FNR==1') )
CAPTURE_SOUND_DEVICE=($(arecord -l | grep -i card | grep -o '[0-9]\+:' | cut -c 1 | awk 'FNR==2') )
: ${REC_DEVICE:=$(echo "hw:${CAPTURE_SOUND_CARDS},${CAPTURE_SOUND_DEVICE}" | grep 'hw:[0-9]' || echo 'hw:0,0')}

PLAYBACK_SOUND_CARDS=( $(aplay -l | grep -i card | grep -o '[0-9]\+:' | cut -c 1 | awk 'FNR==1') )
PLAYBACK_SOUND_DEVICE=($(aplay -l | grep -i card | grep -o '[0-9]\+:' | cut -c 1 | awk 'FNR==2') )
: ${PLAY_DEVICE:=$(echo "hw:${PLAYBACK_SOUND_CARDS},${PLAYBACK_SOUND_DEVICE}" | grep 'hw:[0-9]' || echo 'hw:0,0')}

: ${DEVICE:=$PLAY_DEVICE} #dafault use playback device

: ${TYPE:='loopback'}
: ${FILE:='test.snd'}

CAP_STRING=`aplay -D $DEVICE --dump-hw-params -d 1 /dev/zero 2>&1`
if [ "$TYPE" == "capture" ] ; then
	CAP_STRING=`arecord -D $DEVICE --dump-hw-params -d 1 $FILE 2>&1`
fi

: ${SAMPLERATE:=$(get_default_val "$CAP_STRING" "RATE")}
: ${SAMPLEFORMAT:='S16_LE'}
: ${PERIODSIZE:=$(get_default_val "$CAP_STRING" "PERIOD_SIZE" 1)}
: ${BUFFERSIZE:=$(get_default_val "$CAP_STRING" "BUFFER_SIZE" 1)}
: ${DURATION:='10'}
: ${CHANNEL:=$(get_default_val "$CAP_STRING" "CHANNELS")}
: ${OPMODE:='0'}
: ${ACCESSTYPE:='0'}
: ${CAPTURELOGFLAG:='0'}
PLAY_CARD_ID=${PLAY_DEVICE:3:1}
REC_CARD_ID=${REC_DEVICE:3:1}

audio_type='stereo'
if [ $CHANNEL -eq 1 ] ; then
	audio_type='mono' #channels=1
fi

if [ $OPMODE -eq 0 ] ; then
	OPMODEARG=""
else
	OPMODEARG="-N" #nonblocking mode
fi

if [ $ACCESSTYPE -eq 0 ] ; then
	ACCESSTYPEARG=""
elif [ $ACCESSTYPE -eq 1 ] ; then
	ACCESSTYPEARG="-M"  #mmap stream
fi

if [ $PERIODSIZE -eq $BUFFERSIZE ] ; then
	let BUFFERSIZE=BUFFERSIZE*2
fi


########################### REUSABLE TEST LOGIC ###############################

# Print the test params.
echo " ****************** TEST PARAMETERS ******************"
echo " TYPE         : $TYPE"
echo " DEVICE       : $DEVICE"
echo " REC_DEVICE   : $REC_DEVICE"
echo " PLAY_DEVICE  : $PLAY_DEVICE"
echo " DURATION     : $DURATION"
echo " SAMPLERATE   : $SAMPLERATE"
echo " SAMPLEFORMAT : $SAMPLEFORMAT"
echo " PERIODSIZE   : $PERIODSIZE"
echo " BUFFERSIZE   : $BUFFERSIZE"
echo " CHANNEL      : $CHANNEL"
echo " OPMODE       : $OPMODE"
echo " FILE         : $FILE"
echo " ACCESSTYPE   : $ACCESSTYPE"

case "$TYPE" in
capture)
	do_cmd arecord -D "$DEVICE" -f "$SAMPLEFORMAT" $FILE -d "$DURATION"\
	-r "$SAMPLERATE" -c "$CHANNEL" "$ACCESSTYPEARG" "$OPMODEARG"\
	--buffer-size=$BUFFERSIZE --period-size $PERIODSIZE;;
playback)
	if [ ! -s $FILE ] ; then
		echo "$FILE Does not exists or has size zero. Using /dev/urandom as input file to generate noise"
		FILE="/dev/urandom"
	fi
	do_cmd aplay -D "$DEVICE" -f "$SAMPLEFORMAT" $FILE -d "$DURATION"\
	-r "$SAMPLERATE" -f "$SAMPLEFORMAT" -c "$CHANNEL" "$ACCESSTYPEARG"\
	"$OPMODEARG"  --buffer-size=$BUFFERSIZE --period-size $PERIODSIZE;;
loopback)
	do_cmd arecord -D "$REC_DEVICE" -f "$SAMPLEFORMAT" -d "$DURATION"\
	  -r "$SAMPLERATE" -c "$CHANNEL" "$ACCESSTYPEARG" "$OPMODEARG"\
	  --buffer-size=$BUFFERSIZE --period-size $PERIODSIZE "|"\
	aplay -D "$PLAY_DEVICE" -f "$SAMPLEFORMAT" -d "$DURATION"\
	  -r "$SAMPLERATE" -c "$CHANNEL" "$ACCESSTYPEARG" "$OPMODEARG"\
	  --buffer-size=$BUFFERSIZE --period-size $PERIODSIZE;;
esac	
