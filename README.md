# rk_audio_test
Refer to the audio test contents of LTP-DDT, NXP, and BAT to rewrite and improve compatibility on the RK platform.

##test:  
###1.rk_alsa_tests.sh  
Varies the volume by playing the audio in backgroung using amixer interface.  
　　1.1.ALSA memory access type test  
　　1.2.ALSA operation mode test  
　　1.3.ALSA memory access type test  
　　1.4.Testing for channel configurations  
　　1.5.Testing for various period sizes  
　　1.6.Testing for various sampling irates  
　　1.7.Testing for various sampling formats  
　　1.8.Testing for higher sample rates  
　　1.9.ALSA stress test  
  
###2.rk_speaker_test.sh  
  Run speaker-test utility with all available options to test sound output  
  
###3.rk_amixer_switch_toggle.sh  
  Toggles the switch by playing the audio in backgroung using amixer.  
  
###4.rk_amixer_volume_setting.sh  
  Varies the volume by playing the audio in backgroung using amixer interface.  

##tool:  
###rk_alsa_test_tool.sh  
  Captures/Plays/loopbacks the audio for given parameters  

