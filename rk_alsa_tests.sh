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

#source rk_alsa_test_tool.sh

CAPTURE_SOUND_CARDS=( $(arecord -l | grep -i card | grep -o '[0-9]\+:' | cut -c 1 | awk 'FNR==1') )
CAPTURE_SOUND_DEVICE=($(arecord -l | grep -i card | grep -o '[0-9]\+:' | cut -c 1 | awk 'FNR==2') )
: ${REC_DEVICE:=$(echo "hw:${CAPTURE_SOUND_CARDS},${CAPTURE_SOUND_DEVICE}" | grep 'hw:[0-9]' || echo 'hw:0,0')}

PLAYBACK_SOUND_CARDS=( $(aplay -l | grep -i card | grep -o '[0-9]\+:' | cut -c 1 | awk 'FNR==1') )
PLAYBACK_SOUND_DEVICE=($(aplay -l | grep -i card | grep -o '[0-9]\+:' | cut -c 1 | awk 'FNR==2') )
: ${PLAY_DEVICE:=$(echo "hw:${PLAYBACK_SOUND_CARDS},${PLAYBACK_SOUND_DEVICE}" | grep 'hw:[0-9]' || echo 'hw:0,0')}

ARECORD_CAP_STRING=`arecord -D $REC_DEVICE --dump-hw-params -d 1 /dev/zero 2>&1`
APLAY_CAP_STRING=`aplay -D $PLAY_DEVICE --dump-hw-params -d 1 /dev/zero 2>&1`

echo " ****************** AUDIO DEV INFO ******************"
aplay -l
arecord -l
echo " ****************** PLAY HW PARAMS*******************"
echo "$ARECORD_CAP_STRING"
echo " ****************** PLAY HW PARAMS*******************"
echo "$APLAY_CAP_STRING"

#alsa_accesstype
# @name ALSA memory access type test
# @desc Loopback the audio with Non-Interleaved format or mmap access.
#       a) Access Type   : Access Type (0->RW_INTERLEAVED, 1->MMAP_INTERLEAVED)

#ALSA_XS_FUNC_LOOPBACK_ACCESSTYPE_NONINTER_01
bash rk_alsa_test_tool.sh -t loopback -a 0 -d 10
#ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_NONINTER_02
bash rk_alsa_test_tool.sh -t loopback -a 0 -d 60
#ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_NONINTER_03
bash rk_alsa_test_tool.sh -t loopback -a 0 -d 300
#ALSA_XS_FUNC_LOOPBACK_ACCESSTYPE_MMAP_01
bash rk_alsa_test_tool.sh -t loopback -a 1 -d 10
#ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_MMAP_02
bash rk_alsa_test_tool.sh -t loopback -a 1 -d 60
#ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_MMAP_03
bash rk_alsa_test_tool.sh -t loopback -a 1 -d 300

#ALSA_S_FUNC_PLAYBACK_ACCESSTYPE_NONINTER_01
bash rk_alsa_test_tool.sh -t playback -a 0 -F /home/root/ALSA_M_FUNC_PLAYBACK_ACCESSTYPE_NONINTER_01.wav
#ALSA_S_FUNC_PLAYBACK_ACCESSTYPE_MMAP_01
bash rk_alsa_test_tool.sh -t playback -a 1 -F /home/root/ALSA_M_FUNC_PLAYBACK_ACCESSTYPE_MMAP_01.wav
#ALSA_XS_FUNC_CAPTURE_ACCESSTYPE_NONINTER_01
bash rk_alsa_test_tool.sh -t capture -a 0 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_NONINTER_01.snd;
bash rk_alsa_test_tool.sh -t playback -a 0 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_NONINTER_01.snd
#ALSA_XS_FUNC_CAPTURE_ACCESSTYPE_MMAP_01
bash rk_alsa_test_tool.sh -t capture -a 1 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_MMAP_01.snd;
bash rk_alsa_test_tool.sh -t playback -a 1 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_MMAP_01.snd


#alsa_opmode
# @name ALSA operation mode
# @desc Testing Blocking and non-blocking mode of operation.
#ALSA_XS_FUNC_CAP_OPMODE_BLK_01
bash rk_alsa_test_tool.sh -t capture -o 0 -F ALSA_M_FUNC_CAP_OPMODE_BLK_01.snd ;
bash rk_alsa_test_tool.sh -t playback -o 0 -F ALSA_M_FUNC_CAP_OPMODE_BLK_01.snd
#ALSA_S_FUNC_PLAYBK_OPMODE_BLK
bash rk_alsa_test_tool.sh -t playback -o 0 -F /home/root/ALSA_M_FUNC_PLAYBK_OPMODE_BLK.wav
#ALSA_XS_FUNC_LOOPBK_OPMODE_BLK_01
bash rk_alsa_test_tool.sh -t loopback -o 0 -d 10
#ALSA_S_FUNC_LOOPBK_OPMODE_BLK_02
bash rk_alsa_test_tool.sh -t loopback -o 0 -d 60
#ALSA_S_FUNC_LOOPBK_OPMODE_BLK_03
bash rk_alsa_test_tool.sh -t loopback -o 0 -d 300
#ALSA_XS_FUNC_CAP_OPMODE_NONBLK_01
bash rk_alsa_test_tool.sh -t capture -o 1 -F ALSA_M_FUNC_CAP_OPMODE_NONBLK_01.snd ;
bash rk_alsa_test_tool.sh -t playback -o 1 -F ALSA_M_FUNC_CAP_OPMODE_NONBLK_01.snd
#ALSA_S_FUNC_PLAYBK_OPMODE_NONBLK
bash rk_alsa_test_tool.sh -t playback -o 1 -F /home/root/ALSA_M_FUNC_PLAYBK_OPMODE_NONBLK.wav
#ALSA_XS_FUNC_LOOPBK_OPMODE_NONBLK_01
bash rk_alsa_test_tool.sh -t loopback -o 1 -d 10
#ALSA_S_FUNC_LOOPBK_OPMODE_NONBLK_02
bash rk_alsa_test_tool.sh -t loopback -o 1 -d 60
#ALSA_S_FUNC_LOOPBK_OPMODE_NONBLK_03
bash rk_alsa_test_tool.sh -t loopback -o 1 -d 300


#alsa_buffersize
# @name ALSA memory access type test
# @desc Loopback and Capture the audio with various buffersizes.
#ALSA_XS_FUNC_CAPTURE_BUFSZ_64
bash rk_alsa_test_tool.sh -t capture -b 64 -F ALSA_M_FUNC_CAP_BUFSZ_64.snd ;
bash rk_alsa_test_tool.sh -t playback -b 64 -F ALSA_M_FUNC_CAP_BUFSZ_64.snd
#ALSA_S_FUNC_PLAYBACK_BUFSZ_64
bash rk_alsa_test_tool.sh -t playback -b 64 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_64.wav
#ALSA_XS_FUNC_LOOPBK_BUFSZ_64
bash rk_alsa_test_tool.sh -t loopback -b 64
#ALSA_XS_FUNC_CAPTURE_BUFSZ_512
bash rk_alsa_test_tool.sh -t capture -b 512 -F LSA_M_FUNC_CAP_BUFSZ_512.snd ;
bash rk_alsa_test_tool.sh -t playback -b 512 -F LSA_M_FUNC_CAP_BUFSZ_512.snd
#ALSA_S_FUNC_PLAYBACK_BUFSZ_512
bash rk_alsa_test_tool.sh -t playback -b 512 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_512.wav
#ALSA_XS_FUNC_LOOPBK_BUFSZ_512
bash rk_alsa_test_tool.sh -t loopback -b 512
#ALSA_XS_FUNC_CAPTURE_BUFSZ_32768
bash rk_alsa_test_tool.sh -t capture -b 32768 -F ALSA_M_FUNC_CAP_BUFSZ_32768 ;
bash rk_alsa_test_tool.sh -t playback -b 32768 -F ALSA_M_FUNC_CAP_BUFSZ_32768
#ALSA_S_FUNC_PLAYBACK_BUFSZ_32768
bash rk_alsa_test_tool.sh -t playback -b 512 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_32768.wav
#ALSA_XS_FUNC_LOOPBK_BUFSZ_32768
bash rk_alsa_test_tool.sh -t loopback -b 32768
#ALSA_XS_FUNC_CAPTURE_BUFSZ_65536
bash rk_alsa_test_tool.sh -t capture -b 65536 -F ALSA_M_FUNC_CAP_BUFSZ_65536.snd ;
bash rk_alsa_test_tool.sh -t playback -b 65536 -F ALSA_M_FUNC_CAP_BUFSZ_65536.snd
#ALSA_S_FUNC_PLAYBACK_BUFSZ_65536
bash rk_alsa_test_tool.sh -t playback -b 65536 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_65536.wav
#ALSA_XS_FUNC_LOOPBK_BUFSZ_65536
bash rk_alsa_test_tool.sh -t loopback -b 65536


#alsa_channel
# @name Testing for channel configurations
# @desc Do capture and loopback for different channels of audio
#ALSA_XS_FUNC_CAPTURE_CHANNEL_MONO_1    ;
bash rk_alsa_test_tool.sh -t capture -d 10 -c 1 -F ALSA_S_FUNC_CAPTURE_CHANNEL_1.snd ;
bash rk_alsa_test_tool.sh -t playback -d 10 -c 1 -F ALSA_S_FUNC_CAPTURE_CHANNEL_1.snd
#ALSA_S_FUNC_CAPTURE_CHANNEL_MONO_2
bash rk_alsa_test_tool.sh -t capture -d 60 -c 1 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd ;
bash rk_alsa_test_tool.sh -t playback -d 60 -c 1 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd
#ALSA_S_FUNC_CAPTURE_CHANNEL_MONO_3
bash rk_alsa_test_tool.sh -t capture -d 300 -c 1 -F ALSA_L_FUNC_CAPTURE_CHANNEL_3.snd ;
bash rk_alsa_test_tool.sh -t playback -d 300 -c 1 -F ALSA_L_FUNC_CAPTURE_CHANNEL_3.snd
#ALSA_XS_FUNC_LOOPBK_CHANNEL_MONO_1
bash rk_alsa_test_tool.sh -t loopback -c 1 -d 10
#ALSA_S_FUNC_LOOPBK_CHANNEL_MONO_2
bash rk_alsa_test_tool.sh -t loopback -c 1 -d 60
#ALSA_S_FUNC_LOOPBK_CHANNEL_MONO_3
bash rk_alsa_test_tool.sh -t loopback -c 1 -d 300
#ALSA_XS_FUNC_CAPTURE_CHANNEL_STERIO_1
bash rk_alsa_test_tool.sh -t capture -d 10 -c 2 -F ALSA_S_FUNC_CAPTURE_CHANNEL_2.snd ;
bash rk_alsa_test_tool.sh -t playback -d 10 -c 2 -F ALSA_S_FUNC_CAPTURE_CHANNEL_2.snd
#ALSA_S_FUNC_CAPTURE_CHANNEL_STERIO_2
bash rk_alsa_test_tool.sh -t capture -d 60 -c 2 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd ;
bash rk_alsa_test_tool.sh -t playback -d 60 -c 2 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd
#ALSA_M_STRESS_CAPTURE_CHANNEL_STERIO_3
bash rk_alsa_test_tool.sh -t capture -d 300 -c 2 -F ALSA_L_STRESS_CAPTURE_CHANNEL_2.snd ;
bash rk_alsa_test_tool.sh -t playback -d 300 -c 2 -F ALSA_L_STRESS_CAPTURE_CHANNEL_2.snd
#ALSA_XS_FUNC_LOOPBK_CHANNEL_STERIO_1
bash rk_alsa_test_tool.sh -t loopback -c 2 -d 10
#ALSA_S_FUNC_LOOPBK_CHANNEL_STERIO_2
bash rk_alsa_test_tool.sh -t loopback -c 2 -d 60
#ALSA_S_FUNC_LOOPBK_CHANNEL_STERIO_3
bash rk_alsa_test_tool.sh -t loopback -c 2 -d 300


#alsa_periodsize
# @name Testing for various period sizes
# @desc Do capture, playback and loopback for various period sizes
#ALSA_S_FUNC_CAP_PRDSIZE_1
bash rk_alsa_test_tool.sh -t capture -p 1 -F ALSA_M_FUNC_CAP_PRDSIZE_1.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 1 -F ALSA_M_FUNC_CAP_PRDSIZE_1.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_1
bash rk_alsa_test_tool.sh -t loopback -p 1 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_2
bash rk_alsa_test_tool.sh -t capture -p 2 -F ALSA_M_FUNC_CAP_PRDSIZE_2.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 2 -F ALSA_M_FUNC_CAP_PRDSIZE_2.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_2
bash rk_alsa_test_tool.sh -t loopback -p 2 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_4
bash rk_alsa_test_tool.sh -t capture -p 4 -F ALSA_M_FUNC_CAP_PRDSIZE_4.snd ;
bash rk_alsa_test_tool.sh -t playback -p 4 -F ALSA_M_FUNC_CAP_PRDSIZE_4.snd
#ALSA_S_FUNC_LOOPBK_PRDSIZE_4
bash rk_alsa_test_tool.sh -t loopback -p 4
#ALSA_S_FUNC_CAP_PRDSIZE_8
bash rk_alsa_test_tool.sh -t capture -p 8 -F ALSA_M_FUNC_CAP_PRDSIZE_8.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 8 -F ALSA_M_FUNC_CAP_PRDSIZE_8.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_8
bash rk_alsa_test_tool.sh -t loopback -p 8 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_16
bash rk_alsa_test_tool.sh -t capture -p 16 -F ALSA_M_FUNC_CAP_PRDSIZE_16.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 16 -F ALSA_M_FUNC_CAP_PRDSIZE_16.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_16
bash rk_alsa_test_tool.sh -t loopback -p 16 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_32
bash rk_alsa_test_tool.sh -t capture -p 32 -F ALSA_M_FUNC_CAP_PRDSIZE_32.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 32 -F ALSA_M_FUNC_CAP_PRDSIZE_32.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_32
bash rk_alsa_test_tool.sh -t loopback -p 32 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_64
bash rk_alsa_test_tool.sh -t capture -p 64 -F ALSA_M_FUNC_CAP_PRDSIZE_64.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 64 -F ALSA_M_FUNC_CAP_PRDSIZE_64.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_64
bash rk_alsa_test_tool.sh -t loopback -p 64 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_128
bash rk_alsa_test_tool.sh -t capture -p 128 -F ALSA_M_FUNC_CAP_PRDSIZE_128.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 128 -F ALSA_M_FUNC_CAP_PRDSIZE_128.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_128
bash rk_alsa_test_tool.sh -t loopback -p 128 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_256
bash rk_alsa_test_tool.sh -t capture -p 256 -F ALSA_M_FUNC_CAP_PRDSIZE_256.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 256 -F ALSA_M_FUNC_CAP_PRDSIZE_256.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_256
bash rk_alsa_test_tool.sh -t loopback -p 256 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_512
bash rk_alsa_test_tool.sh -t capture -p 512 -F ALSA_M_FUNC_CAP_PRDSIZE_512.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 512 -F ALSA_M_FUNC_CAP_PRDSIZE_512.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_512
bash rk_alsa_test_tool.sh -t loopback -p 512 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_1024
bash rk_alsa_test_tool.sh -t capture -p 1024 -F ALSA_M_FUNC_CAP_PRDSIZE_1024.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 1024 -F ALSA_M_FUNC_CAP_PRDSIZE_1024.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_1024
bash rk_alsa_test_tool.sh -t loopback -p 1024 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_2046
bash rk_alsa_test_tool.sh -t capture -p 2046 -F ALSA_M_FUNC_CAP_PRDSIZE_2046.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 2046 -F ALSA_M_FUNC_CAP_PRDSIZE_2046.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_2046
bash rk_alsa_test_tool.sh -t loopback -p 2046 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_4096
bash rk_alsa_test_tool.sh -t capture -p 4096 -F ALSA_M_FUNC_CAP_PRDSIZE_4096.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 4096 -F ALSA_M_FUNC_CAP_PRDSIZE_4096.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_4096
bash rk_alsa_test_tool.sh -t loopback -p 4096 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_8192
bash rk_alsa_test_tool.sh -t capture -p 8192 -F ALSA_M_FUNC_CAP_PRDSIZE_8192.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 8192 -F ALSA_M_FUNC_CAP_PRDSIZE_8192.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_8192
bash rk_alsa_test_tool.sh -t loopback -p 8192 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_16384
bash rk_alsa_test_tool.sh -t capture -p 16384 -F ALSA_M_FUNC_CAP_PRDSIZE_16384.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 16384 -F ALSA_M_FUNC_CAP_PRDSIZE_16384.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_16384
bash rk_alsa_test_tool.sh -t loopback -p 16384 -d 60
#ALSA_S_FUNC_CAP_PRDSIZE_32768
bash rk_alsa_test_tool.sh -t capture -p 32768 -F ALSA_M_FUNC_CAP_PRDSIZE_32768.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -p 32768 -F ALSA_M_FUNC_CAP_PRDSIZE_32768.snd -d 60
#ALSA_S_FUNC_LOOPBK_PRDSIZE_32768
bash rk_alsa_test_tool.sh -t loopback -p 32768 -d 60


#alsa_samplerate
# @name Testing for various sampling irates
# @desc Do capture and loopback for various sample rates
#ALSA_S_FUNC_CAP_SMPRT_8000
bash rk_alsa_test_tool.sh -t capture -r 8000 -F ALSA_M_FUNC_CAP_SMPRT_8000.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -r 8000 -F ALSA_M_FUNC_CAP_SMPRT_8000.snd -d 60
#ALSA_S_FUNC_LOOPBK_SMPRT_8000
bash rk_alsa_test_tool.sh -t loopback -r 8000 -d 60
#ALSA_S_FUNC_CAP_SMPRT_11025
bash rk_alsa_test_tool.sh -t capture -r 11025 -F ALSA_M_FUNC_CAP_SMPRT_11025.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -r 11025 -F ALSA_M_FUNC_CAP_SMPRT_11025.snd -d 60
#ALSA_S_FUNC_LOOPBK_SMPRT_11025
bash rk_alsa_test_tool.sh -t loopback -r 11025 -d 60
#ALSA_S_FUNC_CAP_SMPRT_16000
bash rk_alsa_test_tool.sh -t capture -r 16000 -F ALSA_M_FUNC_CAP_SMPRT_16000.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -r 16000 -F ALSA_M_FUNC_CAP_SMPRT_16000.snd -d 60
#ALSA_S_FUNC_LOOPBK_SMPRT_16000
bash rk_alsa_test_tool.sh -t loopback -r 16000 -d 60
#ALSA_S_FUNC_CAP_SMPRT_22050
bash rk_alsa_test_tool.sh -t capture -r 22050 -F ALSA_M_FUNC_CAP_SMPRT_22050.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -r 22050 -F ALSA_M_FUNC_CAP_SMPRT_22050.snd -d 60
#ALSA_S_FUNC_LOOPBK_SMPRT_22050
bash rk_alsa_test_tool.sh -t loopback -r 22050 -d 60
#ALSA_S_FUNC_CAP_SMPRT_24000
bash rk_alsa_test_tool.sh -t capture -r 24000 -F ALSA_M_FUNC_CAP_SMPRT_24000.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -r 24000 -F ALSA_M_FUNC_CAP_SMPRT_24000.snd -d 60
#ALSA_S_FUNC_LOOPBK_SMPRT_24000
bash rk_alsa_test_tool.sh -t loopback -r 24000 -d 60
#ALSA_S_FUNC_CAP_SMPRT_32000
bash rk_alsa_test_tool.sh -t capture -r 32000 -F ALSA_M_FUNC_CAP_SMPRT_32000.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -r 32000 -F ALSA_M_FUNC_CAP_SMPRT_32000.snd -d 60
#ALSA_S_FUNC_LOOPBK_SMPRT_32000
bash rk_alsa_test_tool.sh -t loopback -r 32000 -d 60

#ALSA_S_FUNC_CAP_SMPRT_44100
bash rk_alsa_test_tool.sh -t capture -r 44100 -F ALSA_S_FUNC_CAP_SMPRT_44100.snd ;
bash rk_alsa_test_tool.sh -t playback -r 44100 -F ALSA_S_FUNC_CAP_SMPRT_44100.snd
#ALSA_S_FUNC_LOOPBK_SMPRT_44100
bash rk_alsa_test_tool.sh -t loopback -r 44100

#ALSA_S_FUNC_CAP_SMPRT_48000
bash rk_alsa_test_tool.sh -t capture -r 48000 -F ALSA_S_FUNC_CAP_SMPRT_48000.snd ;
bash rk_alsa_test_tool.sh -t playback -r 48000 -F ALSA_S_FUNC_CAP_SMPRT_48000.snd
#ALSA_S_FUNC_LOOPBK_SMPRT_48000
bash rk_alsa_test_tool.sh -t loopback -r 48000
#ALSA_S_FUNC_CAP_SMPRT_88200
bash rk_alsa_test_tool.sh -t capture -r 88200 -F ALSA_M_FUNC_CAP_SMPRT_88200.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -r 88200 -F ALSA_M_FUNC_CAP_SMPRT_88200.snd -d 60
#ALSA_S_FUNC_LOOPBK_SMPRT_88200
bash rk_alsa_test_tool.sh -t loopback -r 88200 -d 60
#ALSA_S_FUNC_CAP_SMPRT_96000
bash rk_alsa_test_tool.sh -t capture -r 96000 -F ALSA_M_FUNC_CAP_SMPRT_96000.snd -d 60 ;
bash rk_alsa_test_tool.sh -t playback -r 96000 -F ALSA_M_FUNC_CAP_SMPRT_96000.snd -d 60
#ALSA_S_FUNC_LOOPBK_SMPRT_96000
bash rk_alsa_test_tool.sh -t loopback -r 96000 -d 60
#ALSA_S_FUNC_PLAYBACK_SMPRT_8000
bash rk_alsa_test_tool.sh -t playback -r 8000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_8000.wav -d 60
#ALSA_S_FUNC_PLAYBACK_SMPRT_11025
bash rk_alsa_test_tool.sh -t playback -r 11025 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_11025.wav -d 60
#ALSA_S_FUNC_PLAYBACK_SMPRT_16000
bash rk_alsa_test_tool.sh -t playback -r 16000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_16000.wav -d 60
#ALSA_S_FUNC_PLAYBACK_SMPRT_24000
bash rk_alsa_test_tool.sh -t playback -r 24000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_24000.wav -d 60
#ALSA_S_FUNC_PLAYBACK_SMPRT_32000
bash rk_alsa_test_tool.sh -t playback -r 32000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_32000.wav -d 60
#ALSA_S_FUNC_PLAYBACK_SMPRT_44100
bash rk_alsa_test_tool.sh -t playback -r 44100 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_44100.wav -d 60
#ALSA_S_FUNC_PLAYBACK_SMPRT_48000
bash rk_alsa_test_tool.sh -t playback -r 48000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_48000.wav -d 60
#ALSA_S_FUNC_PLAYBACK_SMPRT_88200
bash rk_alsa_test_tool.sh -t playback -r 88200 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_88200.wav -d 60
#ALSA_S_FUNC_PLAYBACK_SMPRT_96000
bash rk_alsa_test_tool.sh -t playback -r 96000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_96000.wav -d 60


#alsa_sampleformat
# @name Testing for various sampling formats
# @desc Do capture and loopback for various sample formats
#ALSA_XS_FUNC_CAP_SMPFMT_S8
bash rk_alsa_test_tool.sh -t capture -f S8 -F ALSA_M_FUNC_CAP_SMPFMT_S8.snd ;
bash rk_alsa_test_tool.sh -t playback -f S8 -F ALSA_M_FUNC_CAP_SMPFMT_S8.snd
#ALSA_XS_FUNC_LOOPBK_SMPFMT_S8
bash rk_alsa_test_tool.sh -t loopback -f S8
#ALSA_XS_FUNC_CAP_SMPFMT_S16_LE
bash rk_alsa_test_tool.sh -t capture -f S16_LE -F ALSA_M_FUNC_CAP_SMPFMT_S16_LE.snd ;
bash rk_alsa_test_tool.sh -t playback -f S16_LE -F ALSA_M_FUNC_CAP_SMPFMT_S16_LE.snd
#ALSA_XS_FUNC_LOOPBK_SMPFMT_S16_LE
bash rk_alsa_test_tool.sh -t loopback -f S16_LE
#ALSA_XS_FUNC_CAP_SMPFMT_S24_LE
bash rk_alsa_test_tool.sh -t capture -f S24_LE -F ALSA_M_FUNC_CAP_SMPFMT_S24_LE.snd ;
 bash rk_alsa_test_tool.sh -t playback -f S24_LE -F ALSA_M_FUNC_CAP_SMPFMT_S24_LE.snd
#ALSA_XS_FUNC_LOOPBK_SMPFMT_S24_LE
bash rk_alsa_test_tool.sh -t loopback -f S24_LE
#ALSA_XS_FUNC_CAP_SMPFMT_S32_LE
bash rk_alsa_test_tool.sh -t capture -f S32_LE -F ALSA_M_FUNC_CAP_SMPFMT_S32_LE.snd ;
bash rk_alsa_test_tool.sh -t playback -f S32_LE -F ALSA_M_FUNC_CAP_SMPFMT_S32_LE.snd
#ALSA_XS_FUNC_LOOPBK_SMPFMT_S32_LE
bash rk_alsa_test_tool.sh -t loopback -f S32_LE

#alsa_higher_samplerate
# @name Testing for various sampling irates
# @desc Do capture and loopback for higher sample rates
#ALSA_XS_FUNC_CAP_SMPRT_192000 
bash rk_alsa_test_tool.sh -t capture -r 192000 -F ALSA_M_FUNC_CAP_SMPRT_192000.snd -d 30;
bash rk_alsa_test_tool.sh -t playback -r 192000 -F ALSA_M_FUNC_CAP_SMPRT_192000.snd -d 30
#ALSA_XS_FUNC_LOOPBK_SMPRT_192000 
bash rk_alsa_test_tool.sh -t loopback -r 192000 -d 30
#ALSA_S_FUNC_PLAYBACK_SMPRT_192000 
bash rk_alsa_test_tool.sh -t playback -r 192000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_192000 -d 60

#alsa_stress
# @name ALSA stress test
# @desc Doing long duration test for capture,playback and loopback.
#ALSA_M_STRESS_CAPTURE
bash rk_alsa_test_tool.sh -t capture -d 1000 -F ALSA_L_STRESS_CAPTURE.snd;
bash rk_alsa_test_tool.sh -t playback -d 1000 -F ALSA_L_STRESS_CAPTURE.snd
#ALSA_M_STRESS_LOOPBACKbash rk_alsa_test_tool.sh -t loopback -d 1000