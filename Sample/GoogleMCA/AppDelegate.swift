//
//  AppDelegate.swift
//  GoogleMCA
//
//  Created by Ilan Klein on 15/02/2016.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit
import BMSCore
import BMSSecurity

///In order for the app to work you need to do the following things: 
///1. In this file : Enter your Bluemix's app data (Url, GUID and region) and your app's protected resource's path
///2. Download the .plist file supplied by Google's developer console (GoogleService-Info.plist) and add it to this project
///3. In info.plist file: Enter your "REVERSED_CLIENT_ID" from the .plist file downloaded from Google's developer console

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let backendURL = "{ENTER YOUR BACKANDURL}"
    private let backendGUID = "{ENTER YOUR GUID}"
    internal static let resourceURL = "{ENTER THE PATH TO YOUR PROTECTED RESOURCE (e.g. /protectedResource)" // any protected resource

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
                
        BMSClient.sharedInstance.initializeWithBluemixAppRoute(backendURL, bluemixAppGUID: backendGUID, bluemixRegion: "your region, choose from BMSClient.REGION_XXX or add your own")
        GoogleAuthenticationManager.sharedInstance.register()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // [START openurl]
    func application(application: UIApplication,
        openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            return GoogleAuthenticationManager.sharedInstance.handleApplicationOpenUrl(openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    @available(iOS 9.0, *)
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return GoogleAuthenticationManager.sharedInstance.handleApplicationOpenUrl(openURL: url, options: options)
    }
    // [END openurl]
}

