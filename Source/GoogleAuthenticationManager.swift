//
//  BMSGoogleAuth.swift
//  SwiftGoogle
//
//  Created by Ilan Klein on 08/02/2016.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
import BMSCore
import BMSSecurity
import BMSAnalyticsAPI

#if swift(>=3.0)
public class GoogleAuthenticationManager : NSObject, AuthenticationDelegate, GIDSignInDelegate, GIDSignInUIDelegate{
    
    private static let GOOGLE_REALM = "wl_googleRealm";
    private static let ID_TOKEN_KEY = "idToken";
    private static let GOOGLE_APP_ID_KEY = "gClientId"
    
    public var localVC : UIViewController?
    private var authContext: AuthenticationContext?
    static let logger = Logger.logger(forName: "bmssdk.security.GoogleAuthenticationManager")
    
    public static let sharedInstance:GoogleAuthenticationManager = GoogleAuthenticationManager()
    
    private override init() {
        super.init()
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        if (configureError != nil) {
            print("We have an error! \(configureError)")
        }
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    public func register() {
        MCAAuthorizationManager.sharedInstance.registerAuthenticationDelegate(self, realm: GoogleAuthenticationManager.GOOGLE_REALM)
    }
    
    public func onAuthenticationChallengeReceived(_ authContext : AuthenticationContext, challenge : AnyObject) {
        self.authContext = authContext
        
        guard let appID = challenge[GoogleAuthenticationManager.GOOGLE_APP_ID_KEY] as? String, appID == GIDSignIn.sharedInstance().clientID
            else{
                authContext.submitAuthenticationFailure([NSLocalizedDescriptionKey:"App Id from server doesn't match the one defined in the .plist file"])
                return
                
        }
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    public func onAuthenticationSuccess(_ info : AnyObject?){
        authContext = nil
        GoogleAuthenticationManager.logger.debug(message: "onAuthenticationSuccess info = \(info)")
    }
    
    public func onAuthenticationFailure(_ info : AnyObject?){
        authContext = nil
    }
    
    
    public func logout(completionHandler: BmsCompletionHandler?){
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
        MCAAuthorizationManager.sharedInstance.logout(completionHandler)
    }
    
    
    @objc
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let idToken = user.authentication.idToken // Safe to send to the server
            if let unwrappedAuthContext = authContext {
                unwrappedAuthContext.submitAuthenticationChallengeAnswer([GoogleAuthenticationManager.ID_TOKEN_KEY: idToken!])
            }
        } else {
            authContext?.submitAuthenticationFailure(nil)
            print("\(error.localizedDescription)")
        }
    }
    
    @objc
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        //        print ("Got disconnected")
    }
    
    public func handleApplicationOpenUrl(openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    public func handleApplicationOpenUrl(openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL!,
            sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
            annotation: options[UIApplicationOpenURLOptionsAnnotationKey] as? String)
    }
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    
    @objc
    public func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        // no needed work for now
    }
    
    // Present a view that prompts the user to sign in with Google
    @objc
    public func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController, self.localVC == nil {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            self.localVC = topController
        }
        
        localVC!.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    @objc
    public func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        localVC!.dismiss(animated: true, completion: nil)
        localVC = nil
    }
}
#else
public class GoogleAuthenticationManager : NSObject, AuthenticationDelegate, GIDSignInDelegate, GIDSignInUIDelegate{
    
    private static let GOOGLE_REALM = "wl_googleRealm";
    private static let ID_TOKEN_KEY = "idToken";
    private static let GOOGLE_APP_ID_KEY = "gClientId"
    
    public var localVC : UIViewController?
    private var authContext: AuthenticationContext?
    static let logger = Logger.logger(forName: "bmssdk.security.GoogleAuthenticationManager")
    
    public static let sharedInstance:GoogleAuthenticationManager = GoogleAuthenticationManager()
    
    private override init() {
        super.init()
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        if (configureError != nil) {
            print("We have an error! \(configureError)")
        }
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    public func register() {
        MCAAuthorizationManager.sharedInstance.registerAuthenticationDelegate(self, realm: GoogleAuthenticationManager.GOOGLE_REALM)
    }
    
    public func onAuthenticationChallengeReceived(authContext : AuthenticationContext, challenge : AnyObject) {
        self.authContext = authContext
        
        guard let appID = challenge[GoogleAuthenticationManager.GOOGLE_APP_ID_KEY] as? String where appID == GIDSignIn.sharedInstance().clientID
            else{
                authContext.submitAuthenticationFailure([NSLocalizedDescriptionKey:"App Id from server doesn't match the one defined in the .plist file"])
                return
                
        }
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    public func onAuthenticationSuccess(info : AnyObject?){
        authContext = nil
        GoogleAuthenticationManager.logger.debug("onAuthenticationSuccess info = \(info)")
    }
    
    public func onAuthenticationFailure(info : AnyObject?){
        authContext = nil
    }
    
    
    public func logout(completionHandler: BmsCompletionHandler?){
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
        MCAAuthorizationManager.sharedInstance.logout(completionHandler)
    }
    
    
    @objc
    public func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error == nil) {
            let idToken = user.authentication.idToken // Safe to send to the server
            if let unwrappedAuthContext = authContext {
                unwrappedAuthContext.submitAuthenticationChallengeAnswer([GoogleAuthenticationManager.ID_TOKEN_KEY: idToken])
            }
        } else {
            authContext?.submitAuthenticationFailure(nil)
            print("\(error.localizedDescription)")
        }
    }
    
    @objc
    public func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        //        print ("Got disconnected")
    }
    
    public func handleApplicationOpenUrl(openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    public func handleApplicationOpenUrl(openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey] as? String)
    }
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    
    @objc
    public func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        // no needed work for now
    }
    
    // Present a view that prompts the user to sign in with Google
    @objc
    public func signIn(signIn: GIDSignIn!, presentViewController viewController: UIViewController!) {
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController where self.localVC == nil {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            self.localVC = topController
        }
        
        localVC!.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    @objc
    public func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
        localVC!.dismissViewControllerAnimated(true, completion: nil)
        localVC = nil
    }
}
#endif
