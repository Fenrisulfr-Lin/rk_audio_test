
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
ALSA_XS_FUNC_LOOPBACK_ACCESSTYPE_NONINTER_01     ; do_cmd 'alsa_tests.sh -t loopback -a 0 -d 10'
ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_NONINTER_02     ; do_cmd 'alsa_tests.sh -t loopback -a 0 -d 60'
ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_NONINTER_03     ; do_cmd 'alsa_tests.sh -t loopback -a 0 -d 300'
ALSA_XS_FUNC_LOOPBACK_ACCESSTYPE_MMAP_01     ; do_cmd 'alsa_tests.sh -t loopback -a 1 -d 10'
ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_MMAP_02     ; do_cmd 'alsa_tests.sh -t loopback -a 1 -d 60'
ALSA_S_FUNC_LOOPBACK_ACCESSTYPE_MMAP_03     ; do_cmd 'alsa_tests.sh -t loopback -a 1 -d 300'
ALSA_S_FUNC_PLAYBACK_ACCESSTYPE_NONINTER_01     ; do_cmd 'alsa_tests.sh -t playback -a 0 -F /home/root/ALSA_M_FUNC_PLAYBACK_ACCESSTYPE_NONINTER_01.wav'  
ALSA_S_FUNC_PLAYBACK_ACCESSTYPE_MMAP_01     ; do_cmd 'alsa_tests.sh -t playback -a 1 -F /home/root/ALSA_M_FUNC_PLAYBACK_ACCESSTYPE_MMAP_01.wav'
ALSA_XS_FUNC_CAPTURE_ACCESSTYPE_NONINTER_01     ; do_cmd 'alsa_tests.sh -t capture -a 0 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_NONINTER_01.snd';do_cmd 'alsa_tests.sh -t playback -a 0 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_NONINTER_01.snd'
ALSA_XS_FUNC_CAPTURE_ACCESSTYPE_MMAP_01     ; do_cmd 'alsa_tests.sh -t capture -a 1 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_MMAP_01.snd'; do_cmd 'alsa_tests.sh -t playback -a 1 -F ALSA_M_FUNC_CAPTURE_ACCESSTYPE_MMAP_01.snd'

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
ALSA_XS_FUNC_CAP_OPMODE_BLK_01     ; do_cmd 'alsa_tests.sh -t capture -o 0 -F ALSA_M_FUNC_CAP_OPMODE_BLK_01.snd'; do_cmd 'alsa_tests.sh -t playback -o 0 -F ALSA_M_FUNC_CAP_OPMODE_BLK_01.snd'
ALSA_S_FUNC_PLAYBK_OPMODE_BLK     ; do_cmd 'alsa_tests.sh -t playback -o 0 -F /home/root/ALSA_M_FUNC_PLAYBK_OPMODE_BLK.wav'
ALSA_XS_FUNC_LOOPBK_OPMODE_BLK_01     ; do_cmd 'alsa_tests.sh -t loopback -o 0 -d 10'
ALSA_S_FUNC_LOOPBK_OPMODE_BLK_02     ; do_cmd 'alsa_tests.sh -t loopback -o 0 -d 60'
ALSA_S_FUNC_LOOPBK_OPMODE_BLK_03     ; do_cmd 'alsa_tests.sh -t loopback -o 0 -d 300'
ALSA_XS_FUNC_CAP_OPMODE_NONBLK_01     ; do_cmd 'alsa_tests.sh -t capture -o 1 -F ALSA_M_FUNC_CAP_OPMODE_NONBLK_01.snd'; do_cmd 'alsa_tests.sh -t playback -o 1 -F ALSA_M_FUNC_CAP_OPMODE_NONBLK_01.snd'
ALSA_S_FUNC_PLAYBK_OPMODE_NONBLK     ; do_cmd 'alsa_tests.sh -t playback -o 1 -F /home/root/ALSA_M_FUNC_PLAYBK_OPMODE_NONBLK.wav'
ALSA_XS_FUNC_LOOPBK_OPMODE_NONBLK_01     ; do_cmd 'alsa_tests.sh -t loopback -o 1 -d 10'
ALSA_S_FUNC_LOOPBK_OPMODE_NONBLK_02     ; do_cmd 'alsa_tests.sh -t loopback -o 1 -d 60'
ALSA_S_FUNC_LOOPBK_OPMODE_NONBLK_03     ; do_cmd 'alsa_tests.sh -t loopback -o 1 -d 300'

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
ALSA_XS_FUNC_CAPTURE_BUFSZ_64     ; do_cmd 'alsa_tests.sh -t capture -b 64 -F ALSA_M_FUNC_CAP_BUFSZ_64.snd'; do_cmd 'alsa_tests.sh -t playback -b 64 -F ALSA_M_FUNC_CAP_BUFSZ_64.snd'
ALSA_S_FUNC_PLAYBACK_BUFSZ_64     ; do_cmd 'alsa_tests.sh -t playback -b 64 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_64.wav'
ALSA_XS_FUNC_LOOPBK_BUFSZ_64     ; do_cmd 'alsa_tests.sh -t loopback -b 64'
ALSA_XS_FUNC_CAPTURE_BUFSZ_512     ; do_cmd 'alsa_tests.sh -t capture -b 512 -F LSA_M_FUNC_CAP_BUFSZ_512.snd';do_cmd 'alsa_tests.sh -t playback -b 512 -F LSA_M_FUNC_CAP_BUFSZ_512.snd'
ALSA_S_FUNC_PLAYBACK_BUFSZ_512     ; do_cmd 'alsa_tests.sh -t playback -b 512 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_512.wav'
ALSA_XS_FUNC_LOOPBK_BUFSZ_512     ; do_cmd 'alsa_tests.sh -t loopback -b 512'
ALSA_XS_FUNC_CAPTURE_BUFSZ_32768     ; do_cmd 'alsa_tests.sh -t capture -b 32768 -F ALSA_M_FUNC_CAP_BUFSZ_32768'; do_cmd 'alsa_tests.sh -t playback -b 32768 -F ALSA_M_FUNC_CAP_BUFSZ_32768'
ALSA_S_FUNC_PLAYBACK_BUFSZ_32768     ; do_cmd 'alsa_tests.sh -t playback -b 512 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_32768.wav'
ALSA_XS_FUNC_LOOPBK_BUFSZ_32768     ; do_cmd 'alsa_tests.sh -t loopback -b 32768'
ALSA_XS_FUNC_CAPTURE_BUFSZ_65536     ; do_cmd 'alsa_tests.sh -t capture -b 65536 -F ALSA_M_FUNC_CAP_BUFSZ_65536.snd';do_cmd 'alsa_tests.sh -t playback -b 65536 -F ALSA_M_FUNC_CAP_BUFSZ_65536.snd'
ALSA_S_FUNC_PLAYBACK_BUFSZ_65536     ; do_cmd 'alsa_tests.sh -t playback -b 65536 -F /home/root/ALSA_M_FUNC_PLAYBACK_BUFSZ_65536.wav'
ALSA_XS_FUNC_LOOPBK_BUFSZ_65536     ; do_cmd 'alsa_tests.sh -t loopback -b 65536'

alsa_channel
# @name Testing for channel configurations
# @desc Do capture and loopback for different channels of audio
# @requires sound
ALSA_XS_FUNC_CAPTURE_CHANNEL_MONO_1    ; do_cmd 'alsa_tests.sh -t capture -d 10 -c 1 -F ALSA_S_FUNC_CAPTURE_CHANNEL_1.snd'; do_cmd 'alsa_tests.sh -t playback -d 10 -c 1 -F ALSA_S_FUNC_CAPTURE_CHANNEL_1.snd'
ALSA_S_FUNC_CAPTURE_CHANNEL_MONO_2     ;do_cmd 'alsa_tests.sh -t capture -d 60 -c 1 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd'; do_cmd 'alsa_tests.sh -t playback -d 60 -c 1 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd'
ALSA_S_FUNC_CAPTURE_CHANNEL_MONO_3     ;do_cmd 'alsa_tests.sh -t capture -d 300 -c 1 -F ALSA_L_FUNC_CAPTURE_CHANNEL_3.snd'; do_cmd 'alsa_tests.sh -t playback -d 300 -c 1 -F ALSA_L_FUNC_CAPTURE_CHANNEL_3.snd'
ALSA_XS_FUNC_LOOPBK_CHANNEL_MONO_1     ;do_cmd 'alsa_tests.sh -t loopback -c 1 -d 10'
ALSA_S_FUNC_LOOPBK_CHANNEL_MONO_2     ;do_cmd 'alsa_tests.sh -t loopback -c 1 -d 60'
ALSA_S_FUNC_LOOPBK_CHANNEL_MONO_3     ;do_cmd 'alsa_tests.sh -t loopback -c 1 -d 300'
ALSA_XS_FUNC_CAPTURE_CHANNEL_STERIO_1     ;do_cmd 'alsa_tests.sh -t capture -d 10 -c 2 -F ALSA_S_FUNC_CAPTURE_CHANNEL_2.snd';do_cmd 'alsa_tests.sh -t playback -d 10 -c 2 -F ALSA_S_FUNC_CAPTURE_CHANNEL_2.snd'
ALSA_S_FUNC_CAPTURE_CHANNEL_STERIO_2     ;do_cmd 'alsa_tests.sh -t capture -d 60 -c 2 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd'; do_cmd 'alsa_tests.sh -t playback -d 60 -c 2 -F ALSA_M_FUNC_CAPTURE_CHANNEL_2.snd'
ALSA_M_STRESS_CAPTURE_CHANNEL_STERIO_3     ;do_cmd 'alsa_tests.sh -t capture -d 300 -c 2 -F ALSA_L_STRESS_CAPTURE_CHANNEL_2.snd'; do_cmd 'alsa_tests.sh -t playback -d 300 -c 2 -F ALSA_L_STRESS_CAPTURE_CHANNEL_2.snd'
ALSA_XS_FUNC_LOOPBK_CHANNEL_STERIO_1     ;do_cmd 'alsa_tests.sh -t loopback -c 2 -d 10'
ALSA_S_FUNC_LOOPBK_CHANNEL_STERIO_2     ;do_cmd 'alsa_tests.sh -t loopback -c 2 -d 60'
ALSA_S_FUNC_LOOPBK_CHANNEL_STERIO_3     ;do_cmd 'alsa_tests.sh -t loopback -c 2 -d 300'

alsa_periodsize
# @name Testing for various period sizes
# @desc Do capture, playback and loopback for various period sizes
# @requires sound
ALSA_S_FUNC_CAP_PRDSIZE_1     ;do_cmd 'alsa_tests.sh -t capture -p 1 -F ALSA_M_FUNC_CAP_PRDSIZE_1.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 1 -F ALSA_M_FUNC_CAP_PRDSIZE_1.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_1     ;do_cmd 'alsa_tests.sh -t loopback -p 1 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_2     ;do_cmd 'alsa_tests.sh -t capture -p 2 -F ALSA_M_FUNC_CAP_PRDSIZE_2.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 2 -F ALSA_M_FUNC_CAP_PRDSIZE_2.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_2     ;do_cmd 'alsa_tests.sh -t loopback -p 2 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_4     ;do_cmd 'alsa_tests.sh -t capture -p 4 -F ALSA_M_FUNC_CAP_PRDSIZE_4.snd';do_cmd 'alsa_tests.sh -t playback -p 4 -F ALSA_M_FUNC_CAP_PRDSIZE_4.snd'
ALSA_S_FUNC_LOOPBK_PRDSIZE_4     ;do_cmd 'alsa_tests.sh -t loopback -p 4'
ALSA_S_FUNC_CAP_PRDSIZE_8     ;do_cmd 'alsa_tests.sh -t capture -p 8 -F ALSA_M_FUNC_CAP_PRDSIZE_8.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 8 -F ALSA_M_FUNC_CAP_PRDSIZE_8.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_8     ;do_cmd 'alsa_tests.sh -t loopback -p 8 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_16     ;do_cmd 'alsa_tests.sh -t capture -p 16 -F ALSA_M_FUNC_CAP_PRDSIZE_16.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 16 -F ALSA_M_FUNC_CAP_PRDSIZE_16.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_16     ;do_cmd 'alsa_tests.sh -t loopback -p 16 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_32     ;do_cmd 'alsa_tests.sh -t capture -p 32 -F ALSA_M_FUNC_CAP_PRDSIZE_32.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 32 -F ALSA_M_FUNC_CAP_PRDSIZE_32.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_32     ;do_cmd 'alsa_tests.sh -t loopback -p 32 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_64     ;do_cmd 'alsa_tests.sh -t capture -p 64 -F ALSA_M_FUNC_CAP_PRDSIZE_64.snd -d 60';do_cmd 'alsa_tests.sh -t playback -p 64 -F ALSA_M_FUNC_CAP_PRDSIZE_64.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_64     ;do_cmd 'alsa_tests.sh -t loopback -p 64 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_128     ;do_cmd 'alsa_tests.sh -t capture -p 128 -F ALSA_M_FUNC_CAP_PRDSIZE_128.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 128 -F ALSA_M_FUNC_CAP_PRDSIZE_128.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_128     ;do_cmd 'alsa_tests.sh -t loopback -p 128 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_256     ;do_cmd 'alsa_tests.sh -t capture -p 256 -F ALSA_M_FUNC_CAP_PRDSIZE_256.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 256 -F ALSA_M_FUNC_CAP_PRDSIZE_256.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_256     ;do_cmd 'alsa_tests.sh -t loopback -p 256 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_512     ;do_cmd 'alsa_tests.sh -t capture -p 512 -F ALSA_M_FUNC_CAP_PRDSIZE_512.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 512 -F ALSA_M_FUNC_CAP_PRDSIZE_512.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_512     ;do_cmd 'alsa_tests.sh -t loopback -p 512 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_1024     ;do_cmd 'alsa_tests.sh -t capture -p 1024 -F ALSA_M_FUNC_CAP_PRDSIZE_1024.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 1024 -F ALSA_M_FUNC_CAP_PRDSIZE_1024.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_1024     ;do_cmd 'alsa_tests.sh -t loopback -p 1024 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_2046     ;do_cmd 'alsa_tests.sh -t capture -p 2046 -F ALSA_M_FUNC_CAP_PRDSIZE_2046.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 2046 -F ALSA_M_FUNC_CAP_PRDSIZE_2046.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_2046     ;do_cmd 'alsa_tests.sh -t loopback -p 2046 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_4096     ;do_cmd 'alsa_tests.sh -t capture -p 4096 -F ALSA_M_FUNC_CAP_PRDSIZE_4096.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 4096 -F ALSA_M_FUNC_CAP_PRDSIZE_4096.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_4096     ;do_cmd 'alsa_tests.sh -t loopback -p 4096 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_8192     ;do_cmd 'alsa_tests.sh -t capture -p 8192 -F ALSA_M_FUNC_CAP_PRDSIZE_8192.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 8192 -F ALSA_M_FUNC_CAP_PRDSIZE_8192.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_8192     ;do_cmd 'alsa_tests.sh -t loopback -p 8192 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_16384     ;do_cmd 'alsa_tests.sh -t capture -p 16384 -F ALSA_M_FUNC_CAP_PRDSIZE_16384.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 16384 -F ALSA_M_FUNC_CAP_PRDSIZE_16384.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_16384     ;do_cmd 'alsa_tests.sh -t loopback -p 16384 -d 60'
ALSA_S_FUNC_CAP_PRDSIZE_32768     ;do_cmd 'alsa_tests.sh -t capture -p 32768 -F ALSA_M_FUNC_CAP_PRDSIZE_32768.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -p 32768 -F ALSA_M_FUNC_CAP_PRDSIZE_32768.snd -d 60'
ALSA_S_FUNC_LOOPBK_PRDSIZE_32768     ;do_cmd 'alsa_tests.sh -t loopback -p 32768 -d 60'

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
ALSA_S_FUNC_CAP_SMPRT_8000     ; do_cmd 'alsa_tests.sh -t capture -r 8000 -F ALSA_M_FUNC_CAP_SMPRT_8000.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 8000 -F ALSA_M_FUNC_CAP_SMPRT_8000.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_8000     ; do_cmd 'alsa_tests.sh -t loopback -r 8000 -d 60'
ALSA_S_FUNC_CAP_SMPRT_11025     ; do_cmd 'alsa_tests.sh -t capture -r 11025 -F ALSA_M_FUNC_CAP_SMPRT_11025.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 11025 -F ALSA_M_FUNC_CAP_SMPRT_11025.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_11025     ; do_cmd 'alsa_tests.sh -t loopback -r 11025 -d 60'
ALSA_S_FUNC_CAP_SMPRT_16000     ; do_cmd 'alsa_tests.sh -t capture -r 16000 -F ALSA_M_FUNC_CAP_SMPRT_16000.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 16000 -F ALSA_M_FUNC_CAP_SMPRT_16000.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_16000     ; do_cmd 'alsa_tests.sh -t loopback -r 16000 -d 60'
ALSA_S_FUNC_CAP_SMPRT_22050     ; do_cmd 'alsa_tests.sh -t capture -r 22050 -F ALSA_M_FUNC_CAP_SMPRT_22050.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 22050 -F ALSA_M_FUNC_CAP_SMPRT_22050.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_22050     ; do_cmd 'alsa_tests.sh -t loopback -r 22050 -d 60'
ALSA_S_FUNC_CAP_SMPRT_24000     ; do_cmd 'alsa_tests.sh -t capture -r 24000 -F ALSA_M_FUNC_CAP_SMPRT_24000.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 24000 -F ALSA_M_FUNC_CAP_SMPRT_24000.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_24000     ; do_cmd 'alsa_tests.sh -t loopback -r 24000 -d 60'
ALSA_S_FUNC_CAP_SMPRT_32000     ; do_cmd 'alsa_tests.sh -t capture -r 32000 -F ALSA_M_FUNC_CAP_SMPRT_32000.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 32000 -F ALSA_M_FUNC_CAP_SMPRT_32000.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_32000     ; do_cmd 'alsa_tests.sh -t loopback -r 32000 -d 60'

ALSA_S_FUNC_CAP_SMPRT_44100	    ; do_cmd 'alsa_tests.sh -t capture -r 44100 -F ALSA_S_FUNC_CAP_SMPRT_44100.snd'; do_cmd 'alsa_tests.sh -t playback -r 44100 -F ALSA_S_FUNC_CAP_SMPRT_44100.snd'
ALSA_S_FUNC_LOOPBK_SMPRT_44100	    ; do_cmd 'alsa_tests.sh -t loopback -r 44100'

ALSA_S_FUNC_CAP_SMPRT_48000	    ; do_cmd 'alsa_tests.sh -t capture -r 48000 -F ALSA_S_FUNC_CAP_SMPRT_48000.snd'; do_cmd 'alsa_tests.sh -t playback -r 48000 -F ALSA_S_FUNC_CAP_SMPRT_48000.snd'
ALSA_S_FUNC_LOOPBK_SMPRT_48000	    ; do_cmd 'alsa_tests.sh -t loopback -r 48000'
ALSA_S_FUNC_CAP_SMPRT_88200     ; do_cmd 'alsa_tests.sh -t capture -r 88200 -F ALSA_M_FUNC_CAP_SMPRT_88200.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 88200 -F ALSA_M_FUNC_CAP_SMPRT_88200.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_88200     ; do_cmd 'alsa_tests.sh -t loopback -r 88200 -d 60'
ALSA_S_FUNC_CAP_SMPRT_96000     ; do_cmd 'alsa_tests.sh -t capture -r 96000 -F ALSA_M_FUNC_CAP_SMPRT_96000.snd -d 60'; do_cmd 'alsa_tests.sh -t playback -r 96000 -F ALSA_M_FUNC_CAP_SMPRT_96000.snd -d 60'
ALSA_S_FUNC_LOOPBK_SMPRT_96000     ; do_cmd 'alsa_tests.sh -t loopback -r 96000 -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_8000     ; do_cmd 'alsa_tests.sh -t playback -r 8000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_8000.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_11025     ; do_cmd 'alsa_tests.sh -t playback -r 11025 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_11025.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_16000     ; do_cmd 'alsa_tests.sh -t playback -r 16000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_16000.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_22050     ; do_cmd 'alsa_tests.sh -t playback -r 22050 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_22050.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_24000     ; do_cmd 'alsa_tests.sh -t playback -r 24000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_24000.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_32000     ; do_cmd 'alsa_tests.sh -t playback -r 32000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_32000.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_44100     ; do_cmd 'alsa_tests.sh -t playback -r 44100 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_44100.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_48000     ; do_cmd 'alsa_tests.sh -t playback -r 48000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_48000.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_88200     ; do_cmd 'alsa_tests.sh -t playback -r 88200 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_88200.wav -d 60'
ALSA_S_FUNC_PLAYBACK_SMPRT_96000     ; do_cmd 'alsa_tests.sh -t playback -r 96000 -F /home/root/ALSA_M_FUNC_PLAYBACK_SMPRT_96000.wav -d 60'

alsa_sampleformat
# @name Testing for various sampling formats
# @desc Do capture and loopback for various sample formats
# @requires sound
ALSA_XS_FUNC_CAP_SMPFMT_S8     ; do_cmd 'alsa_tests.sh -t capture -f S8 -F ALSA_M_FUNC_CAP_SMPFMT_S8.snd'; do_cmd 'alsa_tests.sh -t playback -f S8 -F ALSA_M_FUNC_CAP_SMPFMT_S8.snd'
ALSA_XS_FUNC_LOOPBK_SMPFMT_S8     ; do_cmd 'alsa_tests.sh -t loopback -f S8'
ALSA_XS_FUNC_CAP_SMPFMT_S16_LE     ; do_cmd 'alsa_tests.sh -t capture -f S16_LE -F ALSA_M_FUNC_CAP_SMPFMT_S16_LE.snd'; do_cmd 'alsa_tests.sh -t playback -f S16_LE -F ALSA_M_FUNC_CAP_SMPFMT_S16_LE.snd'
ALSA_XS_FUNC_LOOPBK_SMPFMT_S16_LE     ; do_cmd 'alsa_tests.sh -t loopback -f S16_LE'
ALSA_XS_FUNC_CAP_SMPFMT_S24_LE     ; do_cmd 'alsa_tests.sh -t capture -f S24_LE -F ALSA_M_FUNC_CAP_SMPFMT_S24_LE.snd'; do_cmd 'alsa_tests.sh -t playback -f S24_LE -F ALSA_M_FUNC_CAP_SMPFMT_S24_LE.snd'
ALSA_XS_FUNC_LOOPBK_SMPFMT_S24_LE     ; do_cmd 'alsa_tests.sh -t loopback -f S24_LE'
ALSA_XS_FUNC_CAP_SMPFMT_S32_LE     ; do_cmd 'alsa_tests.sh -t capture -f S32_LE -F ALSA_M_FUNC_CAP_SMPFMT_S32_LE.snd'; do_cmd 'alsa_tests.sh -t playback -f S32_LE -F ALSA_M_FUNC_CAP_SMPFMT_S32_LE.snd'
ALSA_XS_FUNC_LOOPBK_SMPFMT_S32_LE     ; do_cmd 'alsa_tests.sh -t loopback -f S32_LE'
