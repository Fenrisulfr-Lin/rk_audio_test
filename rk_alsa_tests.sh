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




!<<:
alsa_accesstype
# @name ALSA memory access type test
# @desc Loopback the audio with Non-Interleaved format or mmap access.
#       The playback tests in alsa_tests.sh will try to 
#       fetch (if -u option is not specified) a file from server 
#       http://gtopentest-server.gt.design.ti.com based on the
#       sample format, rate and number of channels; if the fetch
#       fails playback will use /dev/urandom as the source. It 
#       is recommended to change the url to an existing server 
#       in the test environment or to add the -u option in the 
#       playback scenarios so that a valid audio source file is 
#       used during playback tests.
# @requires sound
ALSA_XS_FUNC_LOOPBACK_ACCESSTYPE_NONINTER_01 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -a 0 -d 10'
ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_NONINTER_02 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -a 0 -d 60'
ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_NONINTER_03 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -a 0 -d 300'
ALSA_XS_FUNC_LOOPBACK_ACCESSTYPE_MMAP_01 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -a 1 -d 10'
ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_MMAP_02 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -a 1 -d 60'
ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_MMAP_03 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -a 1 -d 300'
ALSA_S_FUNC_PLAYBACK_ACCESSTYPE_NONINTER_01 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -a 0 -F /home/root/ALSA_M_FUNC_PLAYBACK_ACCESSTYPE_NONINTER_01.wav'  
ALSA_S_FUNC_PLAYBACK_ACCESSTYPE_MMAP_01 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -a 1 -F /home/root/ALSA_M_FUNC_PLAYBACK_ACCESSTYPE_MMAP_01.wav'
ALSA_XS_FUNC_CAPTURE_ACCESSTYPE_NONINTER_01 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -a 0 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_NONINTER_01.snd';do_cmd 'alsa_tests.sh -t playback -a 0 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_NONINTER_01.snd'
ALSA_XS_FUNC_CAPTURE_ACCESSTYPE_MMAP_01 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -a 1 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_MMAP_01.snd'; do_cmd 'alsa_tests.sh -t playback -a 1 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_MMAP_01.snd'

alsa_opmode
# @name ALSA operation mode
# @desc Testing Blocking and non-blocking mode of operation.
#       The playback tests in alsa_tests.sh will try to 
#       fetch (if -u option is not specified) a file from server 
#       http://gtopentest-server.gt.design.ti.com based on the
#       sample format, rate and number of channels; if the fetch
#       fails playback will use /dev/urandom as the source. It 
#       is recommended to change the url to an existing server 
#       in the test environment or to add the -u option in the 
#       playback scenarios so that a valid audio source file is 
#       used during playback tests.
# @requires sound
ALSA_XS_FUNC_CAP_OPMODE_BLK_01 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -o 0 -F ALSA_M_FUNC_CAP_OPMODE_BLK_01.snd'; do_cmd 'alsa_tests.sh -t playback -o 0 -F ALSA_M_FUNC_CAP_OPMODE_BLK_01.snd'
ALSA_S_FUNC_PLAYBK_OPMODE_BLK source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -o 0 -F /home/root/ALSA_M_FUNC_PLAYBK_OPMODE_BLK.wav'
ALSA_XS_FUNC_LOOPBK_OPMODE_BLK_01 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -o 0 -d 10'
ALSA_S_FUNC_LOOPBK_OPMODE_BLK_02 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -o 0 -d 60'
ALSA_S_FUNC_LOOPBK_OPMODE_BLK_03 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -o 0 -d 300'
ALSA_XS_FUNC_CAP_OPMODE_NONBLK_01 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -o 1 -F ALSA_M_FUNC_CAP_OPMODE_NONBLK_01.snd'; do_cmd 'alsa_tests.sh -t playback -o 1 -F ALSA_M_FUNC_CAP_OPMODE_NONBLK_01.snd'
ALSA_S_FUNC_PLAYBK_OPMODE_NONBLK source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -o 1 -F /home/root/ALSA_M_FUNC_PLAYBK_OPMODE_NONBLK.wav'
ALSA_XS_FUNC_LOOPBK_OPMODE_NONBLK_01 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -o 1 -d 10'
ALSA_S_FUNC_LOOPBK_OPMODE_NONBLK_02 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -o 1 -d 60'
ALSA_S_FUNC_LOOPBK_OPMODE_NONBLK_03 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -o 1 -d 300'


alsa_buffersize
# @name ALSA memory access type test
# @desc Loopback and Capture the audio with various buffersizes.
#       In loopback arecord will do capture with various buffer 
#       sizes. The playback tests in alsa_tests.sh will try to 
#       fetch (if -u option is not specified) a file from server 
#       http://gtopentest-server.gt.design.ti.com based on the
#       sample format, rate and number of channels; if the fetch
#       fails playback will use /dev/urandom as the source. It 
#       is recommended to change the url to an existing server 
#       in the test environment or to add the -u option in the 
#       playback scenarios so that a valid audio source file is 
#       used during playback tests. 
# @requires sound
ALSA_XS_FUNC_CAPTURE_BUFSZ_64 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -b 64 -F ALSA_M_FUNC_CAP_BUFSZ_64.snd'; do_cmd 'alsa_tests.sh -t playback -b 64 -F ALSA_M_FUNC_CAP_BUFSZ_64.snd'
ALSA_S_FUNC_PLAYBACK_BUFSZ_64 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -b 64 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_64.wav'
ALSA_XS_FUNC_LOOPBK_BUFSZ_64 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -b 64'
ALSA_XS_FUNC_CAPTURE_BUFSZ_512 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -b 512 -F LSA_M_FUNC_CAP_BUFSZ_512.snd';do_cmd 'alsa_tests.sh -t playback -b 512 -F LSA_M_FUNC_CAP_BUFSZ_512.snd'
ALSA_S_FUNC_PLAYBACK_BUFSZ_512 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -b 512 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_512.wav'
ALSA_XS_FUNC_LOOPBK_BUFSZ_512 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -b 512'
ALSA_XS_FUNC_CAPTURE_BUFSZ_32768 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -b 32768 -F ALSA_M_FUNC_CAP_BUFSZ_32768'; do_cmd 'alsa_tests.sh -t playback -b 32768 -F ALSA_M_FUNC_CAP_BUFSZ_32768'
ALSA_S_FUNC_PLAYBACK_BUFSZ_32768 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -b 512 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_32768.wav'
ALSA_XS_FUNC_LOOPBK_BUFSZ_32768 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -b 32768'
ALSA_XS_FUNC_CAPTURE_BUFSZ_65536 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -b 65536 -F ALSA_M_FUNC_CAP_BUFSZ_65536.snd';do_cmd 'alsa_tests.sh -t playback -b 65536 -F ALSA_M_FUNC_CAP_BUFSZ_65536.snd'
ALSA_S_FUNC_PLAYBACK_BUFSZ_65536 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -b 65536 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_65536.wav'
ALSA_XS_FUNC_LOOPBK_BUFSZ_65536 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -b 65536'

alsa_channel
# @name Testing for channel configurations
# @desc Do capture and loopback for different channels of audio
# @requires sound
ALSA_XS_FUNC_CAPTURE_CHANNEL_MONO_1 source 'common.sh' ;do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -d 10 -c 1 -F ALSA_S_FUNC_CAPTURE_CHANNEL_1.snd'; do_cmd 'alsa_tests.sh -t playback -d 10 -c 1 -F ALSA_S_FUNC_CAPTURE_CHANNEL_1.snd'
ALSA_S_FUNC_CAPTURE_CHANNEL_MONO_2 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -d 60 -c 1 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd'; do_cmd 'alsa_tests.sh -t playback -d 60 -c 1 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd'
ALSA_S_FUNC_CAPTURE_CHANNEL_MONO_3 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -d 300 -c 1 -F ALSA_L_FUNC_CAPTURE_CHANNEL_3.snd'; do_cmd 'alsa_tests.sh -t playback -d 300 -c 1 -F ALSA_L_FUNC_CAPTURE_CHANNEL_3.snd'
ALSA_XS_FUNC_LOOPBK_CHANNEL_MONO_1 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -c 1 -d 10'
ALSA_S_FUNC_LOOPBK_CHANNEL_MONO_2 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -c 1 -d 60'
ALSA_S_FUNC_LOOPBK_CHANNEL_MONO_3 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -c 1 -d 300'
ALSA_XS_FUNC_CAPTURE_CHANNEL_STERIO_1 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -d 10 -c 2 -F ALSA_S_FUNC_CAPTURE_CHANNEL_2.snd';do_cmd 'alsa_tests.sh -t playback -d 10 -c 2 -F ALSA_S_FUNC_CAPTURE_CHANNEL_2.snd'
ALSA_S_FUNC_CAPTURE_CHANNEL_STERIO_2 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -d 60 -c 2 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd'; do_cmd 'alsa_tests.sh -t playback -d 60 -c 2 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd'
ALSA_M_STRESS_CAPTURE_CHANNEL_STERIO_3 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -d 300 -c 2 -F ALSA_L_STRESS_CAPTURE_CHANNEL_2.snd'; do_cmd 'alsa_tests.sh -t playback -d 300 -c 2 -F ALSA_L_STRESS_CAPTURE_CHANNEL_2.snd'
ALSA_XS_FUNC_LOOPBK_CHANNEL_STERIO_1 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -c 2 -d 10'
ALSA_S_FUNC_LOOPBK_CHANNEL_STERIO_2 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -c 2 -d 60'
ALSA_S_FUNC_LOOPBK_CHANNEL_STERIO_3 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -c 2 -d 300'

alsa_periodsize
# @name Testing for various period sizes
# @desc Do capture, playback and loopback for various period sizes
# @requires sound
ALSA_S_FUNC_CAP_PRDSIZE_1 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 1 -F ALSA_M_FUNC_CAP_PRDSIZE_1.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 1 -F ALSA_M_FUNC_CAP_PRDSIZE_1.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_1 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 1 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_2 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 2 -F ALSA_M_FUNC_CAP_PRDSIZE_2.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 2 -F ALSA_M_FUNC_CAP_PRDSIZE_2.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_2 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 2 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_4 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 4 -F ALSA_M_FUNC_CAP_PRDSIZE_4.snd';do_cmd 'alsa_tests.sh -t playback -p 4 -F ALSA_M_FUNC_CAP_PRDSIZE_4.snd'
ALSA_S_FUNC_LOOPBK_PRDSIZE_4 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 4'
ALSA_S_FUNC_CAP_PRDSIZE_8 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 8 -F ALSA_M_FUNC_CAP_PRDSIZE_8.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 8 -F ALSA_M_FUNC_CAP_PRDSIZE_8.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_8 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 8 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_16 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 16 -F ALSA_M_FUNC_CAP_PRDSIZE_16.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 16 -F ALSA_M_FUNC_CAP_PRDSIZE_16.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_16 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 16 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_32 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 32 -F ALSA_M_FUNC_CAP_PRDSIZE_32.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 32 -F ALSA_M_FUNC_CAP_PRDSIZE_32.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_32 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 32 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_64 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 64 -F ALSA_M_FUNC_CAP_PRDSIZE_64.snd -d 60';do_cmd 'alsa_tests.sh -t playback -p 64 -F ALSA_M_FUNC_CAP_PRDSIZE_64.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_64 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 64 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_128 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 128 -F ALSA_M_FUNC_CAP_PRDSIZE_128.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 128 -F ALSA_M_FUNC_CAP_PRDSIZE_128.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_128 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 128 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_256 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 256 -F ALSA_M_FUNC_CAP_PRDSIZE_256.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 256 -F ALSA_M_FUNC_CAP_PRDSIZE_256.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_256 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 256 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_512 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 512 -F ALSA_M_FUNC_CAP_PRDSIZE_512.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 512 -F ALSA_M_FUNC_CAP_PRDSIZE_512.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_512 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 512 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_1024 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 1024 -F ALSA_M_FUNC_CAP_PRDSIZE_1024.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 1024 -F ALSA_M_FUNC_CAP_PRDSIZE_1024.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_1024 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 1024 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_2046 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 2046 -F ALSA_M_FUNC_CAP_PRDSIZE_2046.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 2046 -F ALSA_M_FUNC_CAP_PRDSIZE_2046.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_2046 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 2046 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_4096 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 4096 -F ALSA_M_FUNC_CAP_PRDSIZE_4096.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 4096 -F ALSA_M_FUNC_CAP_PRDSIZE_4096.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_4096 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 4096 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_8192 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 8192 -F ALSA_M_FUNC_CAP_PRDSIZE_8192.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 8192 -F ALSA_M_FUNC_CAP_PRDSIZE_8192.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_8192 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 8192 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_16384 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 16384 -F ALSA_M_FUNC_CAP_PRDSIZE_16384.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 16384 -F ALSA_M_FUNC_CAP_PRDSIZE_16384.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_16384 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 16384 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_32768 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t capture -p 32768 -F ALSA_M_FUNC_CAP_PRDSIZE_32768.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 32768 -F ALSA_M_FUNC_CAP_PRDSIZE_32768.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_32768 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'alsa_tests.sh -t loopback -p 32768 -d 60'

alsa_samplerate
# @name Testing for various sampling irates
# @desc Do capture and loopback for various sample rates
#       The playback tests in alsa_tests.sh will try to 
#       fetch (if -u option is not specified) a file from server 
#       http://gtopentest-server.gt.design.ti.com based on the
#       sample format, rate and number of channels; if the fetch
#       fails playback will use /dev/urandom as the source. It 
#       is recommended to change the url to an existing server 
#       in the test environment or to add the -u option in the 
#       playback scenarios so that a valid audio source file is 
#       used during playback tests.
# @requires sound
ALSA_S_FUNC_CAP_SMPRT_8000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -r 8000 -F ALSA_M_FUNC_CAP_SMPRT_8000.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 8000 -F ALSA_M_FUNC_CAP_SMPRT_8000.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_8000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -r 8000 -d 60'
ALSA_S_FUNC_CAP_SMPRT_11025 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -r 11025 -F ALSA_M_FUNC_CAP_SMPRT_11025.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 11025 -F ALSA_M_FUNC_CAP_SMPRT_11025.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_11025 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -r 11025 -d 60'
ALSA_S_FUNC_CAP_SMPRT_16000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -r 16000 -F ALSA_M_FUNC_CAP_SMPRT_16000.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 16000 -F ALSA_M_FUNC_CAP_SMPRT_16000.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_16000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -r 16000 -d 60'
ALSA_S_FUNC_CAP_SMPRT_22050 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -r 22050 -F ALSA_M_FUNC_CAP_SMPRT_22050.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 22050 -F ALSA_M_FUNC_CAP_SMPRT_22050.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_22050 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -r 22050 -d 60'
ALSA_S_FUNC_CAP_SMPRT_24000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -r 24000 -F ALSA_M_FUNC_CAP_SMPRT_24000.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 24000 -F ALSA_M_FUNC_CAP_SMPRT_24000.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_24000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -r 24000 -d 60'
ALSA_S_FUNC_CAP_SMPRT_32000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -r 32000 -F ALSA_M_FUNC_CAP_SMPRT_32000.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 32000 -F ALSA_M_FUNC_CAP_SMPRT_32000.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_32000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -r 32000 -d 60'

ALSA_S_FUNC_CAP_SMPRT_44100	source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -r 44100 -F ALSA_S_FUNC_CAP_SMPRT_44100.snd'; do_cmd 'alsa_tests.sh -t playback -r 44100 -F ALSA_S_FUNC_CAP_SMPRT_44100.snd'
ALSA_S_FUNC_LOOPBK_SMPRT_44100	source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -r 44100'

ALSA_S_FUNC_CAP_SMPRT_48000	source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -r 48000 -F ALSA_S_FUNC_CAP_SMPRT_48000.snd'; do_cmd 'alsa_tests.sh -t playback -r 48000 -F ALSA_S_FUNC_CAP_SMPRT_48000.snd'
ALSA_S_FUNC_LOOPBK_SMPRT_48000	source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -r 48000'
ALSA_S_FUNC_CAP_SMPRT_88200 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -r 88200 -F ALSA_M_FUNC_CAP_SMPRT_88200.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 88200 -F ALSA_M_FUNC_CAP_SMPRT_88200.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_88200 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -r 88200 -d 60'
ALSA_S_FUNC_CAP_SMPRT_96000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -r 96000 -F ALSA_M_FUNC_CAP_SMPRT_96000.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 96000 -F ALSA_M_FUNC_CAP_SMPRT_96000.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_96000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -r 96000 -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_8000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -r 8000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_8000.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_11025 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -r 11025 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_11025.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_16000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -r 16000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_16000.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_22050 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -r 22050 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_22050.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_24000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -r 24000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_24000.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_32000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -r 32000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_32000.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_44100 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -r 44100 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_44100.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_48000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -r 48000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_48000.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_88200 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -r 88200 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_88200.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_96000 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t playback -r 96000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_96000.wav -d 60'

alsa_sampleformat
# @name Testing for various sampling formats
# @desc Do capture and loopback for various sample formats
# @requires sound
ALSA_XS_FUNC_CAP_SMPFMT_S8 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -f S8 -F ALSA_M_FUNC_CAP_SMPFMT_S8.snd'; do_cmd 'alsa_tests.sh -t playback -f S8 -F ALSA_M_FUNC_CAP_SMPFMT_S8.snd'
ALSA_XS_FUNC_LOOPBK_SMPFMT_S8 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -f S8'
ALSA_XS_FUNC_CAP_SMPFMT_S16_LE source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -f S16_LE -F ALSA_M_FUNC_CAP_SMPFMT_S16_LE.snd'; do_cmd 'alsa_tests.sh -t playback -f S16_LE -F ALSA_M_FUNC_CAP_SMPFMT_S16_LE.snd'
ALSA_XS_FUNC_LOOPBK_SMPFMT_S16_LE source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -f S16_LE'
ALSA_XS_FUNC_CAP_SMPFMT_S24_LE source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -f S24_LE -F ALSA_M_FUNC_CAP_SMPFMT_S24_LE.snd'; do_cmd 'alsa_tests.sh -t playback -f S24_LE -F ALSA_M_FUNC_CAP_SMPFMT_S24_LE.snd'
ALSA_XS_FUNC_LOOPBK_SMPFMT_S24_LE source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -f S24_LE'
ALSA_XS_FUNC_CAP_SMPFMT_S32_LE source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t capture -f S32_LE -F ALSA_M_FUNC_CAP_SMPFMT_S32_LE.snd'; do_cmd 'alsa_tests.sh -t playback -f S32_LE -F ALSA_M_FUNC_CAP_SMPFMT_S32_LE.snd'
ALSA_XS_FUNC_LOOPBK_SMPFMT_S32_LE source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'alsa_tests.sh -t loopback -f S32_LE'



