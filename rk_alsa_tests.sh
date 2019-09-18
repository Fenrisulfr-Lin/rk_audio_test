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

#Request: Need to be in the same path as the rk_alsa_test_tool.sh

#record result and time
startTime=`date +%Y%m%d-%H:%M`
startTime_s=`date +%s`
echo "rk_alsa_tests_result" > rk_alsa_tests_result.log
echo "$startTime" >> rk_alsa_tests_result.log

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

echo " ==================AUDIO DEV INFO=================="
aplay -l
arecord -l
echo " ==================CAPTURE HW PARAMS=================="
echo "$ARECORD_CAP_STRING"
echo " ==================PLAYBACK HW PARAMS=================="
echo "$APLAY_CAP_STRING"

#================================alsa_accesstype================================
# @name ALSA memory access type test
# @desc Loopback the audio with Non-Interleaved format or mmap access.
#       a) Access Type   : Access Type (0->RW_INTERLEAVED, 1->MMAP_INTERLEAVED)
TEST_ACESSTYPE_TIME=(10 60 300)
i=0
while [[ TEST_ACESSTYPE_TIME[$i] -ne '' ]]
do      
        #test_type=loopback access_type=RW_INTERLEAVED
	bash rk_alsa_test_tool.sh -t loopback -a 0 \
             -d ${TEST_ACESSTYPE_TIME[$i]} 
        #test_type=loopback access_type=MMAP_INTERLEAVED
        bash rk_alsa_test_tool.sh -t loopback -a 1 \
             -d ${TEST_ACESSTYPE_TIME[$i]} 
	let "i += 1"
done

#ALSA_XS_FUNC_CAPTURE_ACCESSTYPE_RW_INTERLEAVED_01
bash rk_alsa_test_tool.sh -t capture -a 0 \
     -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_RW_INTERLEAVED_01.snd;
bash rk_alsa_test_tool.sh -t playback -a 0 \
     -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_RW_INTERLEAVED_01.snd
#ALSA_XS_FUNC_CAPTURE_ACCESSTYPE_MMAP_INTERLEAVED_01
bash rk_alsa_test_tool.sh -t capture -a 1 \
     -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_MMAP_INTERLEAVED_01.snd;
bash rk_alsa_test_tool.sh -t playback -a 1 \
     -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_MMAP_INTERLEAVED_01.snd

#================================alsa_opmode====================================
# @name ALSA operation mode test
# @desc Testing Blocking and non-blocking mode of operation.

#ALSA_XS_FUNC_CAP_OPMODE_BLK_01
bash rk_alsa_test_tool.sh -t capture -o 0 -F ALSA_M_FUNC_CAP_OPMODE_BLK_01.snd 
bash rk_alsa_test_tool.sh -t playback -o 0 -F ALSA_M_FUNC_CAP_OPMODE_BLK_01.snd
#ALSA_XS_FUNC_CAP_OPMODE_NONBLK_01
bash rk_alsa_test_tool.sh -t capture -o 1 \
     -F ALSA_M_FUNC_CAP_OPMODE_NONBLK_01.snd ;
bash rk_alsa_test_tool.sh -t playback -o 1 \
     -F ALSA_M_FUNC_CAP_OPMODE_NONBLK_01.snd

TEST_OPMODE_TIME=(10 60 300)
i=0
while [[ TEST_OPMODE_TIME[$i] -ne '' ]]
do       
        #test_type=loopback opmode=Blocking
	bash rk_alsa_test_tool.sh -t loopback -o 0 -d ${TEST_OPMODE_TIME[$i]}
        #test_type=loopback opmode=Non-Blocking 
        bash rk_alsa_test_tool.sh -t loopback -o 1 -d ${TEST_OPMODE_TIME[$i]}
	let "i += 1"
done

#================================alsa_buffersize================================
# @name Testing for various buffer sizes
# @desc Loopback and Capture the audio with various buffer izes.
TEST_BUFFERSIZE=(64 512 32768 65536)
i=0
while [[ TEST_BUFFERSIZE[$i] -ne '' ]]
do      
        bash rk_alsa_test_tool.sh -t capture -b ${TEST_BUFFERSIZE[$i]} \
             -F ALSA_M_FUNC_CAP_BUFFER_SIZE_${TEST_BUFFERSIZE[$i]}.snd
        bash rk_alsa_test_tool.sh -t playback -b ${TEST_BUFFERSIZE[$i]} \
             -F ALSA_M_FUNC_CAP_BUFFER_SIZE_${TEST_BUFFERSIZE[$i]}.snd 
        bash rk_alsa_test_tool.sh -t loopback -b ${TEST_BUFFERSIZE[$i]} 
	let "i += 1"
done

#================================alsa_channel===================================
# @name Testing for channels configurations
# @desc Do capture and loopback for different channels of audio
TEST_CHANNEL_TIME=(10 60 300)
i=0
while [[ TEST_CHANNEL_TIME[$i] -ne '' ]]
do       
	bash rk_alsa_test_tool.sh -t capture -c 1 -d ${TEST_CHANNEL_TIME[$i]} \
             -F ALSA_${TEST_CHANNEL_TIME[$i]}s_FUNC_CAPTURE_CHANNELS_1.snd
        bash rk_alsa_test_tool.sh -t playback -c 1 -d ${TEST_CHANNEL_TIME[$i]} \
             -F ALSA_${TEST_CHANNEL_TIME[$i]}s_FUNC_CAPTURE_CHANNELS_1.snd
        bash rk_alsa_test_tool.sh -t loopback -c 1 -d ${TEST_CHANNEL_TIME[$i]}
        bash rk_alsa_test_tool.sh -t capture -c 2 -d ${TEST_CHANNEL_TIME[$i]} \
             -F ALSA_${TEST_CHANNEL_TIME[$i]}s_FUNC_CAPTURE_CHANNELS_2.snd 
        bash rk_alsa_test_tool.sh -t playback -c 2 -d ${TEST_CHANNEL_TIME[$i]} \
             -F ALSA_${TEST_CHANNEL_TIME[$i]}s_FUNC_CAPTURE_CHANNELS_2.snd
        bash rk_alsa_test_tool.sh -t loopback -c 2 -d ${TEST_CHANNEL_TIME[$i]}
	let "i += 1"
done

#================================alsa_periodsize================================
# @name Testing for various period sizes
# @desc Do capture, playback and loopback for various period sizes
TEST_PERIODSIZE=(1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768)
i=0
while [[ TEST_PERIODSIZE[$i] -ne '' ]]
do      
        bash rk_alsa_test_tool.sh -t capture -p ${TEST_PERIODSIZE[$i]} \
             -F ALSA_M_FUNC_CAP_PERIOD_SIZES_${TEST_PERIODSIZE[$i]}.snd -d 60
        bash rk_alsa_test_tool.sh -t playback -p ${TEST_PERIODSIZE[$i]} \
             -F ALSA_M_FUNC_CAP_PERIOD_SIZES_${TEST_PERIODSIZE[$i]}.snd -d 60
        bash rk_alsa_test_tool.sh -t loopback -p ${TEST_PERIODSIZE[$i]} -d 60
	let "i += 1"
done

#================================alsa_samplerate================================
# @name Testing for various sampling irates
# @desc Do capture and loopback for various sample rates
TEST_SAMPLERATE=(8000 11025 16000 22050 24000 32000 44100 48000 88200 96000)
i=0
while [[ TEST_SAMPLERATE[$i] -ne '' ]]
do      
        bash rk_alsa_test_tool.sh -t capture -r ${TEST_SAMPLERATE[$i]} \
             -F ALSA_M_FUNC_CAP_SAMPLE_RATE_${TEST_SAMPLERATE[$i]}.snd -d 60
        bash rk_alsa_test_tool.sh -t playback -r ${TEST_SAMPLERATE[$i]} \
             -F ALSA_M_FUNC_CAP_SAMPLE_RATE_${TEST_SAMPLERATE[$i]}.snd -d 60
        bash rk_alsa_test_tool.sh -t loopback -r ${TEST_SAMPLERATE[$i]} -d 60
	let "i += 1"
done

#================================alsa_sampleformat==============================
# @name Testing for various sampling formats
# @desc Do capture and loopback for various sample formats
TEST_FORMAT=(S8 S16_LE S24_LE S32_LE)
i=0
while [[ $i -lt 4 ]] #String cannot be judged non-empty
do
	bash rk_alsa_test_tool.sh -t capture -f ${TEST_FORMAT[$i]} \
             -F ALSA_M_FUNC_CAP_SAMPLE_FORMAT_${TEST_FORMAT[$i]}.snd
        bash rk_alsa_test_tool.sh -t playback -f ${TEST_FORMAT[$i]} \
             -F ALSA_M_FUNC_CAP_SAMPLE_FORMAT_${TEST_FORMAT[$i]}.snd
        bash rk_alsa_test_tool.sh -t loopback -f ${TEST_FORMAT[$i]}
	let "i += 1"
done

#================================alsa_higher_samplerate=========================
# @name Testing for higher sample rates
# @desc Do capture and loopback for higher sample rates
bash rk_alsa_test_tool.sh -t capture -r 192000 \
     -F ALSA_M_FUNC_CAP_SAMPLE_RATE_192000.snd -d 30;
bash rk_alsa_test_tool.sh -t playback -r 192000 \
     -F ALSA_M_FUNC_CAP_SAMPLE_RATE_192000.snd -d 30
bash rk_alsa_test_tool.sh -t loopback -r 192000 -d 30

#================================alsa_stress====================================
# @name ALSA stress test
# @desc Doing long duration test for capture,playback and loopback.
bash rk_alsa_test_tool.sh -t capture -d 1000 -F ALSA_L_STRESS_CAPTURE.snd;
bash rk_alsa_test_tool.sh -t playback -d 1000 -F ALSA_L_STRESS_CAPTURE.snd
bash rk_alsa_test_tool.sh -t loopback -d 1000

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
     "$sumTime_m minutes and $sumTime_s seconds" >> rk_alsa_tests_result.log