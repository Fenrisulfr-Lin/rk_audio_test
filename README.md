# rk_audio_test  

　　Refer to the audio test contents of LTP-DDT, NXP, and BAT  
to rewrite and improve compatibility on the RK platform.  

## **test script**:  

### **0.rk_alsabat_test.sh**  

　　Use the alsabat tool to perform various tests.  
　　**Can automatically analyze test results.**  
　　**But need external loopback.**  
　　　　0.0 generate mono wav file with default params  
　　　　0.1 generate dual wav file with default params  
　　　　0.2 single line mode, playback  
　　　　0.3 single line mode, capture  
　　　　0.4 play mono wav file and detect  
　　　　0.5 play dual wav file and detect  
　　　　0.6 configurable channel number: 1  
　　　　0.7 configurable channel number: 2  
　　　　0.8 configurable sample rate: 44100  
　　　　0.9 configurable sample rate: 48000  
　　　　0.10 configurable duration: in samples  
　　　　0.11 configurable duration: in seconds  
　　　　0.12 configurable data format: U8  
　　　　0.13 configurable data format: S16_LE  
　　　　0.14 configurable data format: S24_3LE  
　　　　0.15 configurable data format: S32_LE  
　　　　0.16 configurable data format: cd  
　　　　0.17 configurable data format: dat  
　　　　0.18 standalone mode: play and capture  
　　　　0.19 local mode: analyze local file  
　　　　0.20 round trip latency test  
　　　　0.21 noise detect threshold in SNR(dB)  
　　　　0.22 noise detect threshold in noise percentage(%)  
　　　　0.23 power management: S3 test  

### **1.rk_alsa_tests.sh**  

　　Use rk_alsa_test_tool.sh for various audio tests  
　　**The result can be automatically given**  
　　**only if it is judged whether the configuration is successful.**  
　　**However, phenomena such as Caton require manual observation.**  
　　　　1.1 ALSA memory access type test  
　　　　1.2 ALSA operation mode test  
　　　　1.3 Testing for various buffer sizes  
　　　　1.4 Testing for channel configurations  
　　　　1.5 Testing for various period sizes  
　　　　1.6 Testing for various sampling irates  
　　　　1.7 Testing for various sampling formats  
　　　　1.8 Testing for higher sample rates  
　　　　1.9 ALSA stress test  

### **2.rk_speaker_test.sh**  

　　Run speaker-test utility with all available options to test sound output.  
　　**It is best to have manual monitoring,**  
　　**or check the fail and error sections of the log after the test is complete.**  

### **3.rk_amixer_switch_toggle.sh**  

　　Play audio in the background,  
　　then use the amixer switch to test if the path is normal  
　　　　**Need manual monitoring.**  
　　　　**PASS only means the setting is successful,**  
　　　　**but the audio channel may have been turned off and there is no sound.**    

### **4.rk_amixer_volume_setting.sh**  

　　    Play audio in the background,  
　　    then use amixer to set various volume levels.  
　　　　        **Need human monitoring.**  
　　　　        **PASS only means the setting is successful,but the volume may not change.**  
　　
　　

## **test tool/lib:**  

### **rk_alsa_test_tool.sh**  

　　Captures/Plays/loopbacks the audio for given parameters  
　　Tool script for rk_alsa_tests.sh test  

### **alsa-utils-1.1.9**  

　　Audio Test Kit, which is required for all scripts  

### **libfftw3**  

　　Used for noise detection tests of 0.21 and 0.22.  

### **rtcwake**  

　　Used for power management testing of 0.23.  
　　Located in the util-linux toolkit.  
　　This toolkit is available in the general environment.  
