# iOS helloAuthentication Sample Application for Bluemix Mobile Services

The helloAuthentication sample contains a Swift project that you can use to learn more about the Mobile Client Access service.  

### Before you begin
Before you start, make sure you have:

- A [Bluemix](http://bluemix.net) account.
- A Bluemix app with the MCA service bound to it.

#### Configure the Mobile Client Access service

1.	In the Mobile Client Access dashboard, go to the **Authentication** tab to configure your authentication service.  
2.  Choose your authentication type to be Google.
3.  Enter the required configuration settings (Google APP ID for iOS).


### Configure the front end in the helloAuthentication sample
1. Open the `AppDelegate.swift` file. Change the values of the variables named: "backendURL", 'backendGUID" and "resourceURL" to your app's values.
2. Enter your app's region as a parameter for BMSClient.sharedInstance.initializeWithBluemixAppRoute

### Set up Google authentication

Copy the `GoogleAuthenticationManager.swift` file from the `BMSGoogleAuthentication` pod's source folder to your app's folder, and add it to the helloauthentication-swift project.

1. Download the GoogleService-info.plist for you app from Google developers console and add it to your project.
2. Add the REVERSED_CLIENT_ID value from the GoogleService-info.plist file as a "URL Type" of your project.
3. Add your app's Bundle Identifier as a "URL Type" of your project.
4. Add a bridging header to your project and write the following line in it:
```Objective-C
#import <Google/SignIn.h>
```

### Enable Keychain Sharing
When using Xcode 8.x, in order to use BMSGoogleAuthentication, you need to enable Keychain Sharing in your app. You can enable this feature in the Capabilities tab of your target.

### Run the iOS app
Now you can run the iOS application in your iOS emulator or on a physical device.


**Note:** Inside the **ViewController**, a GET request is made to a protected resource in the Node.js runtime on Bluemix. This code has been provided in the MobileFirst Services Starter boilerplate. The Node.js code provided in this boilerplate must be present in order for the sample to work as expected.


**Note:** This application runs on the latest version of XCode (V7.0). You might need to modify the application for Application Transport Security (ATS) changes made in iOS 9. For more information, see the following blog entry: [Connect Your iOS 9 App to Bluemix](https://developer.ibm.com/bluemix/2015/09/16/connect-your-ios-9-app-to-bluemix/).


### License
This package contains sample code provided in source code form. The samples are licensed under the Apache License, Version 2.0 (the "License"). You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and may also view the license in the license.txt file within this package. Also see the notices.txt file within this package for additional notices.
