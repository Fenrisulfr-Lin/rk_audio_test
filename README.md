# rk_audio_test
Refer to the audio test contents of LTP-DDT, NXP, and BAT to rewrite and improve compatibility on the RK platform.

test:
rk_speaker_test.sh  
  Run speaker-test utility with all available options to test sound output  

rk_amixer_switch_toggle.sh  
  Toggles the switch by playing the audio in backgroung using amixer.  

rk_amixer_volume_setting.sh  
  Varies the volume by playing the audio in backgroung using amixer interface.  

rk_alsa_tests.sh  
  Varies the volume by playing the audio in backgroung using amixer interface.  
    1.ALSA memory access type test  
    2.ALSA operation mode test  
    3.ALSA memory access type test  
    4.Testing for channel configurations  
    5.Testing for various period sizes  
    6.Testing for various sampling irates  
    7.Testing for various sampling formats  
    8.Testing for higher sample rates  
    9.ALSA stress test  

tool:  
rk_alsa_test_tool.sh  
  Captures/Plays/loopbacks the audio for given parameters  

