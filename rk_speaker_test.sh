#! /bin/sh
############################################################################### 
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
###############################################################################
# @history 2011-05-13: First version
# @desc Run speaker-test utility with all available options to test sound output 

source "common.sh"  # Import do_cmd(), die() and other functions

############################# Functions #######################################
usage()
{
	echo "run_speaker_test.sh [For options (see speaker-test help)"
	echo " all other args are passed as-is to speaker-test"
	echo " speaker-test help:"
        echo `speaker-test -h`
	exit 1
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
# Define default values if possible

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
    *omap3evm|am37x-evm|beagleboard)
        amixer cset name='Analog Left AUXL Capture Switch' 1 
        amixer cset name='Analog Right AUXR Capture Switch' 1
        amixer cset name='HeadsetL Mixer AudioL1' on
        amixer cset name='HeadsetR Mixer AudioR1' on
        amixer cset name='Headset Playback Volume' 3
	;;
    *da850-omapl138-evm)
        amixer cset name='PCM Playback Volume' 127,127
	;;
*dra7xx-evm)
	amixer sset 'Left DAC Mux',0 'DAC_L2'
	amixer sset 'Right DAC Mux',0 'DAC_R2'
	amixer cset name='HP Playback Switch' On
	amixer cset name='Line Playback Switch' Off
	amixer cset name='PCM Playback Volume' 127
	amixer cset name='Left PGA Mixer Mic3L Switch' On
	amixer cset name='Right PGA Mixer Mic3L Switch' On
	amixer cset name='Left PGA Mixer Line1L Switch' off
	amixer cset name='Right PGA Mixer Line1R Switch' off
	amixer cset name='PGA Capture Switch' on
	amixer cset name='PGA Capture Volume' 6
	;;
esac
# Define default values for variables being overriden

########################### REUSABLE TEST LOGIC ###############################
# DO NOT HARDCODE any value. If you need to use a specific value for your setup
# use USER-DEFINED Params section above.

test_print_trc "Starting speaker-test TEST"

do_cmd "speaker-test $*"



###############################################################################
:<<!


ltp/runtest/ddt/alsa_apeaker_test

# @name ALSA Speaker test utility
# @desc Run speaker-test utility provided by alsa-utils to test the capabilities of the speaker.
# @requires  sound
ALSA_XS_FUNC_SPEAKER_TEST_0001 source 'common.sh' ; do_cmd install_modules.sh 'sound' ; do_cmd 'run_speaker_test.sh -c 1 -t wave -l 5';
ALSA_XS_FUNC_SPEAKER_TEST_0002 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -t wave -l 5';
ALSA_S_FUNC_SPEAKER_TEST_0003 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 1  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0004 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 2  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0005 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 4  -l 10'
ALSA_XS_FUNC_SPEAKER_TEST_0006 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 8  -l 5'
ALSA_S_FUNC_SPEAKER_TEST_0007 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 16  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0008 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 32  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0009 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 64  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0010 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 128  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0011 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 256  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0012 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 512  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0013 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 1024  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0014 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 2046  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0015 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 4096  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0016 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 8192  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0017 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 16384  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0018 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --period 32768  -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0019 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --format S8 -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0020 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --format S16_LE -l 5'
ALSA_S_FUNC_SPEAKER_TEST_0021 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --format S24_LE -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0022 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 --format S32_LE -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0023 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -r 8000 -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0024 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -r 11025 -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0025 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -r 16000 -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0026 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -r 22050 -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0027 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -r 24000 -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0028 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -r 32000 -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0029 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -r 44100 -l 5'
ALSA_S_FUNC_SPEAKER_TEST_0030 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -r 48000 -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0031 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -r 88200 -l 10'
ALSA_S_FUNC_SPEAKER_TEST_0032 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -r 96000 -l 10'
ALSA_M_STRESS_SPEAKER_TEST_0032 source 'common.sh' ; do_cmd install_modules.sh 'sound' ;do_cmd 'run_speaker_test.sh -c 2 -t wave -l 1000'
!
