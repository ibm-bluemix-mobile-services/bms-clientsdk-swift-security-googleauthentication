IBM Bluemix Mobile Services - Client SDK Swift Security - Google
===================================================

This is the Google security component of the Swift SDK for IBM Bluemix Mobile Services.

https://console.ng.bluemix.net/solutions/mobilefirst

## Requirements
* iOS 8.0+
* Xcode 7


## Installation
The Bluemix Mobile Services Google authentication Swift SDK is available via [Cocoapods](http://cocoapods.org/).
To install, add the `BMSGoogleAuthentication` pod to your `Podfile`.

##### iOS
```ruby
use_frameworks!

target 'MyApp' do
    platform :ios, '8.0'
    pod 'BMSGoogleAuthentication'
end
```

After doing so, the pod's sources will be added to your workspace. Copy the **GoogleAuthenticationManager.swift** file from the BMSGoogleAuthentication pod's source folder to you app folder.

Then you need to create a bridging header and add to it the following line:
```Swift
#import <Google/SignIn.h>
```
After doing so add your "REVERSED_CLIENT_ID" (located in the .plist file supplied by Google's developer console) and your "Bundle Identifier" as URL Types in your project.

## Getting started

In order to use the Bluemix Mobile Services Google Authentication Swift SDK, add the following imports in the class which you want to use it in:
```
import BMSCore
import BMSSecurity
import FBSDKLoginKit
```

Connectivity and interaction between your mobile app and the Bluemix services depends on the application ID and application route that are associated with Bluemix application.

The BMSClient API is the entry point for interacting with the SDK. You must invoke the
```
initializeWithBluemixAppRoute(bluemixAppRoute: String?, bluemixAppGUID: String?, bluemixRegion: String)
```

method before any other API calls.</br>

BMSClient provides information about the current SDK level and access to service SDKs. This method is usually in the application delegate of your mobile app.

An example of initializing the MobileFirst Platform for iOS SDK follows:

Initialize SDK with IBM Bluemix application route, ID and the region where your Bluemix application is hosted.
```Swift
BMSClient.sharedInstance.initializeWithBluemixAppRoute(<app route>, bluemixAppGUID: <app guid>, bluemixRegion: BMSClient.<region>)
```

Then you have to register Google as your authentication manager Authentication Delegate to the MCAAuthorizationManager as follows:
```Swift
GoogleAuthenticationManager.sharedInstance.register()
```

The following code sends the openurl requests to the Google Authentication Manager and needs to be added to your AppDelegate.swift file:
```Swift
  func application(application: UIApplication,
        openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            return GoogleAuthenticationManager.sharedInstance.handleApplicationOpenUrl(openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }


    @available(iOS 9.0, *)
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return GoogleAuthenticationManager.sharedInstance.handleApplicationOpenUrl(openURL: url, options: options)
    }
```

=======================
Copyright 2015 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
