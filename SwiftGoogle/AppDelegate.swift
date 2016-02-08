//
//  AppDelegate.swift
//  SwiftGoogle
//
//  Created by Ilan Klein on 02/02/2016.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit
import BMSCore
import BMSSecurity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?

    private static let backendURL = "http://IlanTestSwiftGoogle.mybluemix.net" // your BM application URL
    private static let backendGUID = "d177008b-8fc7-4b81-a3b1-6e0e0b5e2bdc" // the GUID you get from the dashboard
    private static let customResourceURL = "\(backendURL)/protectedResource" // any protected resource
//    private static let customRealm = "customAuthRealm_1" // auth realm

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        BMSClient.sharedInstance.initializeWithBluemixAppRoute(AppDelegate.backendURL, bluemixAppGUID: AppDelegate.backendGUID, bluemixRegionSuffix: BMSClient.REGION_US_SOUTH)
        
        //setting default protocol so that wireshark can look at all of the messages
        BMSClient.defaultProtocol = BMSClient.HTTP_SCHEME
        
        let mcaAuthManager = MCAAuthorizationManager.sharedInstance
        mcaAuthManager.clearAuthorizationData()
        BMSGoogleOAuth.sharedInstance.register()
        
        let callBack:MfpCompletionHandler = {(response: Response?, error: NSError?) in
            if error == nil {
                print ("response:\(response?.responseText), no error")
            } else {
                print ("error")
                //                self.handleAuthorizationFailure(response, error: error)
            }
        }        
        
        mcaAuthManager.obtainAuthorization(callBack)
                return true
    }
    
    // [START openurl]
    func application(application: UIApplication,
        openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            
            return BMSGoogleOAuth.sharedInstance.handleApplicationOpenUrl(openURL: url, sourceApplication: sourceApplication, annotation: annotation)
            
//            return GIDSignIn.sharedInstance().handleURL(url,
//                sourceApplication: sourceApplication,
//                annotation: annotation)
    }
    // [END openurl]
    
    @available(iOS 9.0, *)
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return BMSGoogleOAuth.sharedInstance.handleApplicationOpenUrl(openURL: url, options: options)
        
//        return GIDSignIn.sharedInstance().handleURL(url,
//            sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String?,
//            annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
//    
//    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
//        if (error == nil) {
//            // Perform any operations on signed in user here.
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let name = user.profile.name
//            let email = user.profile.email
//            // ...
//            print("LoggedIn user: \(email) token:\(idToken)")
//
//        } else {
//            print("\(error.localizedDescription)")
//        }
//    }
//    
//    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
//        // Perform any operations when the user disconnects from app here.
//        // ...
//        print ("Got disconnected")
//    } 
    
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


}

