# Bl_project

Bl_Project is a simple app connect to arduino devices to detect falls.

*Support android only.

Bl_Project uses `flutter_bluetooth_serial` plugin.

Check out the link (https://github.com/edufolly/flutter_bluetooth_serial)

TODO:

+ Update the project ID in build.gradle.
+ Add your google-services.json from Firebase
+ Add you own Firestore database in Firebase and create `users` collocation.
+ Update the google map API key in AndroidManifest.xml.
+ Update twilio config in constants/app_constants.dart to enable sms service.
+ Add the mac addresses in constants/app_constants.dart.


# Components:
+ ESP-32 microcontroller
+ MPU-6050 Sensor
+ Bluetooth Radio and Baseband

# Bluetooth Interface 
• Provides UART HCI interface, up to 4 Mbps 
• Provides SDIO/SPI HCI interface 
• Provides PCM/I2S audio interface 

### Screenshots


Sign in page |  Paired devices  |  Add device  |  Device stream page  |
:---:|:---:|:---:|:---:|
![](https://github.com/reza-codes/bl_project/blob/4a7f77bf8c1be2c8f6b3df5e3a63823b99956ff0/screenshots/Screen%20Shot%202022-04-28%20at%2011.42.47%20PM.png?raw=true)  |  ![](https://github.com/reza-codes/bl_project/blob/4a7f77bf8c1be2c8f6b3df5e3a63823b99956ff0/screenshots/Screen%20Shot%202022-04-28%20at%2011.43.11%20PM.png?raw=true)  |  ![](https://github.com/reza-codes/bl_project/blob/4a7f77bf8c1be2c8f6b3df5e3a63823b99956ff0/screenshots/Screen%20Shot%202022-04-28%20at%2011.43.32%20PM.png?raw=true)  |  ![](https://github.com/reza-codes/bl_project/blob/4a7f77bf8c1be2c8f6b3df5e3a63823b99956ff0/screenshots/Screen%20Shot%202022-04-28%20at%2011.45.15%20PM.png?raw=true)



Profile page |  History page  |  Fall details  |  Setting page  |
:---:|:---:|:---:|:---:|
![](https://github.com/reza-codes/bl_project/blob/4a7f77bf8c1be2c8f6b3df5e3a63823b99956ff0/screenshots/Screen%20Shot%202022-04-28%20at%2011.46.44%20PM.png?raw=true)  |  ![](https://github.com/reza-codes/bl_project/blob/4a7f77bf8c1be2c8f6b3df5e3a63823b99956ff0/screenshots/Screen%20Shot%202022-04-28%20at%2011.46.55%20PM.png?raw=true)  |  ![](https://github.com/reza-codes/bl_project/blob/4a7f77bf8c1be2c8f6b3df5e3a63823b99956ff0/screenshots/Screen%20Shot%202022-04-28%20at%2011.47.19%20PM.png?raw=true)  |  ![](https://github.com/reza-codes/bl_project/blob/4a7f77bf8c1be2c8f6b3df5e3a63823b99956ff0/screenshots/Screen%20Shot%202022-04-28%20at%2011.47.38%20PM.png?raw=true)

