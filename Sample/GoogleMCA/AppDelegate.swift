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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /***
     IMPORTANT: Don't forget that for the app to work you must copy the google-info file
     and the following parameters
     ***/
    private static let backendURL = "https://ilantestswiftnew.stage1.mybluemix.net"//"{ENTER YOUR BACKANDURL}"
    private static let backendGUID = "92b0ca84-65c7-475f-9cff-66f661b2eef0"//"{ENTER YOUR GUID}"
    public static let customResourceURL = "\(backendURL)/protectedResource"//"{ENTER THE PATH TO YOUR PROTECTED RESOURCE" // any protected resource
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//        BMSClient.sharedInstance.initializeWithBluemixAppRoute(AppDelegate.backendURL, bluemixAppGUID: AppDelegate.backendGUID, bluemixRegionSuffix: BMSClient.REGION_US_SOUTH)
        
        BMSClient.sharedInstance.initializeWithBluemixAppRoute(AppDelegate.backendURL, bluemixAppGUID: AppDelegate.backendGUID, bluemixRegionSuffix: "stage1-dev.ng.bluemix.net")
        
        //setting default protocol so that wireshark can look at all of the messages
        BMSClient.defaultProtocol = BMSClient.HTTP_SCHEME
        
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

