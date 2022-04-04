# IOS-One2Many
iOSSDKStreaming-one2many Broadcast


## Prerequisite
* To begin, you must possess a good understanding of [Broadcast Extensions](https://developer.apple.com/app-extensions), [AppGroupIDs](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups?language=objc), and [ReplayKit](https://developer.apple.com/documentation/replaykit).
## Requirements

##### System Requirements
* OS X 11.0 or later
* 8GB of RAM memory
   
##### Development Requirements
* Xcode 13.3
* [Click here](https://www.freecodecamp.org/news/how-to-download-and-install-xcode/) to follow instructions on downloading and installation of Xcode on your device. 
* It’s recommended to install Xcode from **App Store**.   

## Installation
### Installing Cocoapods
Open **Terminal** and type command `pod --version` and hit **Enter**.

If command is not found then you don’t have Cocoapods installed on your system. To install Cocoapods, here are the steps to follow:
#### Installing Cocoapods
* Type the following command in **Terminal** `sudo gem install cocoapods` and hit **Enter**
* After installation is complete, type command `pod --version` and hit **Enter** to confirm installation is successful

### Project Signup and Project ID
Register at [VdoTok HomePage](https://vdotok.com) to get **Authentication Token**,**HOST** and **Project ID**

### Code Setup
*	Click on **Code** button 
*	From HTTPS section, copy **repo URL** 
*	Open **Terminal**
*	Go to Desktop **Directory** by typing `cd Desktop` and hit **Enter**
*	And then type `git clone paste_copied_ url` and hit **Enter**
*	After cloning is complete, go to **Demo project’s root directory** by typing `cd path_to_ cloned_project` and hit **Enter**
*	Once inside the project’s root directory type `ls` (LS in small letters) and hit **Enter**.
	You should be able to see a file named **Podfile**
*	Type command `pod install` hit **Enter** and wait until the process is complete

### Updating  Project ID and Authentication Token

*  Get **Project ID** and **Authentication Token** from [Admin Panel](https://userpanel.vdotok.com/login)
*  Double-click to open **.xcworkspace file** in Xcode
*  In struct AuthenticationConstants, replace the values for **PROJECTID**,**HOST** and **AUTHTOKEN** with your values

### Set up App groups
* To establish a connection between your main “Main Target” and “Extension Target”, add **appgoups** in your all targets
* Go to your **Main Target->Signing and Capabilities->Capabilities->App Groups**
* Tap on the **App groups Icon** and create your **Group ID**
* Now checkmark the box to enable **Group ID** and tap on Refresh icon 
* **App Group ID** must be kept same for all targets
* Repeat the above action to your **Screen Share**, and **Screenshare Utility Target**
* Now go to AppsGroup struct, replace the values for **APP_GROUP** and **SCREEN_SHARE_PREFERED_EXTENSION** with your **App Group Identifier** and **Screenshare Target's Bundle Identifier** respectively

### Building On Device
*Please be noted that iOSSDKStreaming does not work for iOS Simulator*

To run on a real device:

   *	Connect your device with MacBook pro
   *	Select your device from the dropdown menu in Xcode
For details on how to run application on a real device, please [click here](https://codewithchris.com/deploy-your-app-on-an-iphone/) to follow instructions.



	     
