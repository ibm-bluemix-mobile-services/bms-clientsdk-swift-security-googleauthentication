IBM Bluemix Mobile Services - Client SDK Swift Security - Google
===================================================

This is the Google security component of the Swift SDK for [IBM Bluemix Mobile Services] (https://console.ng.bluemix.net/docs/mobile/index.html).

## Requirements
* iOS 8.0 or later
* Xcode 7


## Installation
The Bluemix Mobile Services Google authentication Swift SDK is available via [Cocoapods](http://cocoapods.org/).
To install, add the `BMSGoogleAuthentication` pod to your Podfile.

##### iOS
```ruby
use_frameworks!

target 'MyApp' do
    platform :ios, '8.0'
    pod 'BMSGoogleAuthentication'
end
```

After you update your Podfile, the pod's sources are added to your workspace. Copy the `GoogleAuthenticationManager.swift` file from the `BMSGoogleAuthentication` pod's source folder to your app folder.

Then you need to create a bridging header and add the following line to it:
```Swift
#import <Google/SignIn.h>
```
After doing so add your "REVERSED_CLIENT_ID" (located in the `.plist` file you get from the Google developer console) and your "Bundle Identifier" as URL Types in your project.

## Getting started

In order to use the Bluemix Mobile Services Google Authentication Swift SDK, add the following imports in the class which you want to use it in:
```
import BMSCore
import BMSSecurity
```

Connectivity and interaction between your mobile app and the Bluemix services depends on the application ID and application route that are associated with Bluemix application.

The BMSClient and MCAAuthorizationManager API are the entry points for interacting with the SDK. You must invoke the following API before any other API calls:

```
MCAAuthorizationManager.sharedInstance.initialize(tenantId: tenantId, bluemixRegion: regionName)
```

This method is usually called in the application delegate of your mobile app.

You also need to define MCAAuthorizationManager as your authorization manager:
```Swift
BMSClient.sharedInstance.authorizationManager = MCAAuthorizationManager.sharedInstance
```

Then you have to register Google as your authentication manager Authentication Delegate to the MCAAuthorizationManager as follows:
```Swift
GoogleAuthenticationManager.sharedInstance.register()
```

The following code sends the openurl requests to the Google Authentication Manager and needs to be added to your AppDelegate.swift file:
```Swift
func application(_ application: UIApplication,
                   open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return GoogleAuthenticationManager.sharedInstance.handleApplicationOpenUrl(openURL: url, sourceApplication: sourceApplication, annotation: annotation as AnyObject)
  }

  @available(iOS 9.0, *)
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
      return GoogleAuthenticationManager.sharedInstance.handleApplicationOpenUrl(openURL: url, options: options)
  }
```

In order to logout the current logged in user, you must call the following code:
```Swift
GoogleAuthenticationManager.sharedInstance.logout(<callBack>)
```
When the user tries to log in again, they are prompted to authorize Mobile Client Access to use Google for authentication purposes. At that point, the user can click the user name in the upper-right corner of the screen to select and login with another user.

## Sample app
You can use 'pod try BMSGoogleAuthentication' to get a sample application. A readme file with details on how to run the sample application is available in the app's folder.

=======================

Copyright 2016 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
