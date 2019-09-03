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
# @desc Captures/Plays/loopbacks the audio for given parameters
#       The playback tests in alsa_tests.sh will try to 
#       fetch (if -u option is not specified) a file from server 
#       http://gtopentest-server.gt.design.ti.com based on the
#       sample format, rate and number of channels; if the fetch
#       fails playback will use /dev/urandom as the source. It 
#       is recommended to change the url to an existing server 
#       in the test environment or to add the -u option in the 
#       playback scenarios so that a valid audio source file is 
#       used during playback tests.
# @params t) Test type     : Capture,playback,loopback
#         r) Sample rate   : Sample rate (44100,48000,88200,96000 etc)
#         f) Sample Format : Sample Format (S8,S16_LE,S24_LE,S32_LE)
#         p) Period Size   : Period Size (1,2,4,8,etc)
#         b) Buffer Size   : Buffer Size (64,512,32768,65536)
#         d) Duration      : Duration in Secs.
#         c) Channel	   : Channel.
#         F) File Name	   : File name to play from or capture to.
#         o) OpMode		   : OpMode (0->Blocking, 1->Non-Blocking)
#         a) Access Type   : Access Type ( 0->Non Interleaved, 1-> Interleaved, 2->Mmap )
#         D) Audio Device  : Audio Device.
#         R) Record Device : Audio Record Device.
#         P) Playback Device  : Audio PlaybackDevice.
#         l) Capture Log   : Whether to retain captured file or delete.
#         u) URL           : URL of sound file to be played back 
# @history 2011-04-07: First version
# @history 2011-05-13: Removed st_log.sh
# @history 2012-05-30: Added wget support 
source "common.sh"  # Import do_cmd(), die() and other functions

############################# Functions #######################################
usage()
{
	cat <<-EOF >&2
	usage: ./${0##*/} [-t TEST_TYPE] [-D DEVICE] [-R REC_DEVICE] [-P PLAY_DEVICE] [-r SAMPLE_RATE] [-f SAMPLE_FORMAT] [-p PERIOD_SIZE] [-b BUFFER_SIZE] [-c CHANNEL] [-o OpMODE] [-a ACCESS_TYPE] [-d DURATION] [-s BLK_DEVICE]
	-t TEST_TYPE		Test Type. Possible Values are capture,playback,loopback.
	-D DEVICE           Device Name like hw:0,0.
	-R REC_DEVICE           Device Name like hw:0,0.
	-P PLAY_DEVICE           Device Name like hw:0,0.
	-r SAMPLE_RATE		Sample Rate like 44100,48000,88200,96000 etc.
	-f SAMPLE_FORMAT	Sample Format like S8,S16_LE,S24_LE,S32_LE.
	-p PERIOD_SIZE		Period Size like 1,2,4,8,etc.
	-b BUFFER_SIZE		Buffer Size like 64,512,32768,65536.
	-c CHANNEL			Channel like 1,2.
	-F FILENAME			File Name to capture to or playback from	
	-o OpMODE			OpMode (0->Blocking, 1->Non-Blocking)
	-a ACCESS_TYPE		Access Type ( 0->Non Interleaved, 1-> Interleaved,2->Mmap )
	-d DURATION         Dutaion In Secs like 5,10 etc. 
	-l CAPTURELOG_FLAG  Whether to retain captured file or delete.( 1 -> To retain, 0 -> delete )
	-u URL				URL of sound file to be played back
    -s BLK_DEVICE       save file audio src file to block device of type BLK_DEVICE
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
  local result=`echo "$1" | grep -w "$2:" | tr -s " " | cut -d " " -f 2,3 | cut -d "[" -f 2 | cut -d "(" -f 2 | cut -d "]" -f 1 | cut -d ")" -f 1`
  local value_range=($result)
  if [ $# -gt 2 ] ; then
    echo ${value_range[${#value_range[@]} - 1]}
  else
    echo ${value_range[0]}
  fi
}

################################ CLI Params ####################################
# Please use getopts
while getopts  :t:r:f:F:p:b:l:d:c:o:a:D:R:P:u:s:h arg
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
        u)      URL="$OPTARG";;
        s)      BLK_DEVICE="$OPTARG";;
        h)      usage;;
        :)      die "$0: Must supply an argument to -$OPTARG.";; 
        \?)     die "Invalid Option -$OPTARG ";;
esac
done

############################ Default Values for Params ###############################
: ${TYPE:='loopback'}
: ${FILE:='test.snd'}
: ${REC_DEVICE:=$(get_audio_devnodes.sh -d aic -t record -e JAMR | grep 'hw:[0-9]' || echo 'hw:0,0')}
: ${PLAY_DEVICE:=$(get_audio_devnodes.sh -d aic -t play -e JAMR | grep 'hw:[0-9]' || echo 'hw:0,0')}
: ${DEVICE:=$PLAY_DEVICE}

CAP_STRING=`aplay -D $DEVICE --dump-hw-params -d 1 /dev/zero 2>&1`
if [ "$TYPE" == "capture" ] ; then
  CAP_STRING=`arecord -D $DEVICE --dump-hw-params -d 1 $FILE 2>&1`
fi

: ${SAMPLERATE:=$(get_default_val "$CAP_STRING" "RATE")}
: ${SAMPLEFORMAT:=$(get_default_val "$CAP_STRING" "FORMAT")}
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
  audio_type='mono'
fi
fmt_type=$(echo "${SAMPLEFORMAT/_/}" | tr [:upper:] [:lower:])

: ${URL:="http://gtopentest-server.gt.design.ti.com/anonymous/common/Multimedia/Audio/WAV/pcm_${fmt_type}/${SAMPLERATE}/${audio_type}/test_8000_pcm_${fmt_type}_${SAMPLERATE}_${audio_type}_201sec.wav"}

if [ $OPMODE -eq 0 ] ; then
	OPMODEARG=""
else
	OPMODEARG="-N"
fi

if [ $ACCESSTYPE -eq 0 ] ; then
	ACCESSTYPEARG=""
elif [ $ACCESSTYPE -eq 1 ] ; then
	ACCESSTYPEARG="-M"
fi

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
*am37x-evm|omap3evm|beagleboard)
    amixer -c ${REC_CARD_ID} cset name='Analog Left AUXL Capture Switch' 1
    amixer -c ${REC_CARD_ID} cset name='Analog Right AUXR Capture Switch' 1
    amixer -c ${PLAY_CARD_ID} cset name='HeadsetL Mixer AudioL1' on
    amixer -c ${PLAY_CARD_ID} cset name='HeadsetR Mixer AudioR1' on
    amixer -c ${PLAY_CARD_ID} cset name='Headset Playback Volume' 3
;;
*da850-omapl138-evm)
    amixer -c ${PLAY_CARD_ID} cset name='PCM Playback Volume' 127,127 
;;
*dra7xx-evm)
    amixer -c ${PLAY_CARD_ID} sset 'Left DAC Mux',0 'DAC_L2'
    amixer -c ${PLAY_CARD_ID} sset 'Right DAC Mux',0 'DAC_R2'
    amixer -c ${PLAY_CARD_ID} cset name='HP Playback Switch' On
    amixer -c ${PLAY_CARD_ID} cset name='Line Playback Switch' Off
    amixer -c ${PLAY_CARD_ID} cset name='PCM Playback Volume' 127
    amixer -c ${REC_CARD_ID} cset name='Left PGA Mixer Mic3L Switch' On
    amixer -c ${REC_CARD_ID} cset name='Right PGA Mixer Mic3L Switch' On
    amixer -c ${REC_CARD_ID} cset name='Left PGA Mixer Line1L Switch' off
    amixer -c ${REC_CARD_ID} cset name='Right PGA Mixer Line1R Switch' off
    amixer -c ${REC_CARD_ID} cset name='PGA Capture Switch' on
    amixer -c ${REC_CARD_ID} cset name='PGA Capture Volume' 6
;;
*am43xx-epos)                                                      
    amixer -c ${PLAY_CARD_ID} sset 'DAC' 127                                                   
    amixer -c ${PLAY_CARD_ID} sset 'HP Analog' 66                                              
    amixer -c ${PLAY_CARD_ID} sset 'HP Driver' 0 on                                            
    amixer -c ${PLAY_CARD_ID} sset 'HP Left' on                                                
    amixer -c ${PLAY_CARD_ID} sset 'HP Right' on                                               
    amixer -c ${PLAY_CARD_ID} sset 'SP Analog' 127                                             
    amixer -c ${PLAY_CARD_ID} sset 'SP Driver' 0 on                                            
    amixer -c ${PLAY_CARD_ID} sset 'SP Left' on                                                
    amixer -c ${PLAY_CARD_ID} sset 'SP Right' on                                               
    amixer -c ${PLAY_CARD_ID} sset 'Output Left From Left DAC' on                              
    amixer -c ${PLAY_CARD_ID} sset 'Output Right From Right DAC' on                            
    amixer -c ${REC_CARD_ID} sset 'MIC1RP P-Terminal' 'FFR 10 Ohm'                            
    amixer -c ${REC_CARD_ID} sset 'MIC1LP P-Terminal' 'FFR 10 Ohm'                            
    amixer -c ${REC_CARD_ID} sset 'ADC' 40                                                    
    amixer -c ${REC_CARD_ID} cset name='ADC Capture Switch' on                                
;;           
esac

########################### REUSABLE TEST LOGIC ###############################
# DO NOT HARDCODE any value. If you need to use a specific value for your setup
# use USER-DEFINED Params section above.

# Print the test params.

test_print_trc " ****************** TEST PARAMETERS ******************"
test_print_trc " TYPE         : $TYPE"
test_print_trc " DEVICE       : $DEVICE"
test_print_trc " REC_DEVICE   : $REC_DEVICE"
test_print_trc " PLAY_DEVICE  : $PLAY_DEVICE"
test_print_trc " DURATION     : $DURATION"
test_print_trc " SAMPLERATE   : $SAMPLERATE"
test_print_trc " SAMPLEFORMAT : $SAMPLEFORMAT"
test_print_trc " PERIODSIZE   : $PERIODSIZE"
test_print_trc " BUFFERSIZE   : $BUFFERSIZE"
test_print_trc " CHANNEL      : $CHANNEL"
test_print_trc " OPMODE       : $OPMODE"
test_print_trc " FILE         : $FILE"
test_print_trc " ACCESSTYPE   : $ACCESSTYPE"
if test "$URL" != ''
then
test_print_trc " URL          : $URL"
fi
test_print_trc " *************** END OF TEST PARAMETERS ***************"

test_print_trc " ****************** AUDIO DEV INFO ******************"
aplay -l
arecord -l
echo "$CAP_STRING"
test_print_trc " *************** END OF AUDIO DEV INFO ***************"

case "$TYPE" in
	
	capture)
		do_cmd arecord -D "$DEVICE" -f "$SAMPLEFORMAT" $FILE -d "$DURATION" -r "$SAMPLERATE" -c "$CHANNEL" "$ACCESSTYPEARG" "$OPMODEARG" --buffer-size=$BUFFERSIZE --period-size $PERIODSIZE
		;;		
	playback)
        if [ -n "$BLK_DEVICE" ]
        then
            FILE=$(download_to_blk_dev.sh -u $URL -o $FILE -d $BLK_DEVICE) || FILE='test.snd'
        else
		    Wget $URL -O $FILE
        fi

		if [ ! -s $FILE ]
		then
			test_print_trc "$FILE Does not exists or has size zero. Using /dev/urandom as input file to generate noise"
			FILE="/dev/urandom"
		fi
		do_cmd aplay -D "$DEVICE" -f "$SAMPLEFORMAT" $FILE -d "$DURATION" -r "$SAMPLERATE" -f "$SAMPLEFORMAT" -c "$CHANNEL" "$ACCESSTYPEARG" "$OPMODEARG"  --buffer-size=$BUFFERSIZE --period-size $PERIODSIZE
		;;		
	loopback)
		do_cmd arecord -D "$REC_DEVICE" -f "$SAMPLEFORMAT" -d "$DURATION" -r "$SAMPLERATE" -c "$CHANNEL" "$ACCESSTYPEARG" "$OPMODEARG"  --buffer-size=$BUFFERSIZE --period-size $PERIODSIZE "|" aplay -D "$PLAY_DEVICE" -f "$SAMPLEFORMAT" -d "$DURATION" -r "$SAMPLERATE" -c "$CHANNEL" "$ACCESSTYPEARG" "$OPMODEARG"  --buffer-size=$BUFFERSIZE --period-size $PERIODSIZE
		;;		
esac	
