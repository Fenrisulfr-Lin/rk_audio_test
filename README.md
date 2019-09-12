# rk_audio_test
Refer to the audio test contents of LTP-DDT, NXP, and BAT to rewrite and improve compatibility on the RK platform.

##test:  
###1.rk_alsa_tests.sh  
  Varies the volume by playing the audio in backgroung using amixer interface.  
  **Can automatically analyze test results, except 1.8 and 1.9.**  
　　1.1 ALSA memory access type test  
　　1.2 ALSA operation mode test  
　　1.3 ALSA memory access type test  
　　1.4 Testing for channel configurations  
　　1.5 Testing for various period sizes  
　　1.6 Testing for various sampling irates  
　　1.7 Testing for various sampling formats  
　　1.8 Testing for higher sample rates  
　　1.9 ALSA stress test  
  
###2.rk_speaker_test.sh  
  Run speaker-test utility with all available options to test sound output  
  **Need human judgment.**  

###3.rk_amixer_switch_toggle.sh  
  Toggles the switch by playing the audio in backgroung using amixer.  
  **Need human judgment.**  

###4.rk_amixer_volume_setting.sh  
  Varies the volume by playing the audio in backgroung using amixer interface.  
  **Need human judgment.**  

###5.rk_alsabat_test.sh  
  Use the alsabat tool to perform various tests.  
  **Can automatically analyze test results.**  
  **But depending on the environment, there may be misjudgments.**  
	5.0 generate mono wav file with default params  
	5.1 generate dual wav file with default params  
	5.2 single line mode, playback  
	5.3 single line mode, capture  
	5.4 play mono wav file and detect  
	5.5 play dual wav file and detect  
	5.6 configurable channel number: 1  
	5.7 configurable channel number: 2  
	5.8 configurable sample rate: 44100  
	5.9 configurable sample rate: 48000  
	5.10 configurable duration: in samples  
	5.11 configurable duration: in seconds  
	5.12 configurable data format: U8  
	5.13 configurable data format: S16_LE  
	5.14 configurable data format: S24_3LE  
	5.15 configurable data format: S32_LE  
	5.16 configurable data format: cd  
	5.17 configurable data format: dat  
	5.18 standalone mode: play and capture  
	5.19 local mode: analyze local file  
	5.20 round trip latency test  
	5.21 noise detect threshold in SNR(dB)  
	5.22 noise detect threshold in noise percentage(%)  
	5.23 power management: S3 test  

##tool:  
###rk_alsa_test_tool.sh  
  Captures/Plays/loopbacks the audio for given parameters  
###alsa-utils-1.1.9/libfftw3/rtcwake  
  Used for test.  
