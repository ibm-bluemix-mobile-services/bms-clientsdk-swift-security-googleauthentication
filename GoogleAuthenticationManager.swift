//
//  BMSGoogleAuth.swift
//  SwiftGoogle
//
//  Created by Ilan Klein on 08/02/2016.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
import BMSSecurity

public class GoogleAuthenticationManager : NSObject, AuthenticationDelegate, GIDSignInDelegate, GIDSignInUIDelegate{
    
    private static let GOOGLE_REALM = "wl_googleRealm";
    private static let ID_TOKEN_KEY = "idToken";
    private static let GOOGLE_APP_ID_KEY = "gClientId"
    
    
    public var localVC : UIViewController?
    private var authContext: AuthenticationContext?

    public static let sharedInstance:GoogleAuthenticationManager = GoogleAuthenticationManager()
    
    private override init() {
        super.init()
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        if (configureError != nil) {
            print("We have an error! \(configureError)")
        }
        
//        GIDSignIn.sharedInstance().clientID = "129267688709-74504hp4r1g93ar23mcspg6vlmehvtcu.apps.googleusercontent.com"
////        GIDSignIn.sharedInstance().
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    public func register() {
        try! MCAAuthorizationManager.sharedInstance.registerAuthenticationDelegate(self, realm: GoogleAuthenticationManager.GOOGLE_REALM)
    }
    
    public func onAuthenticationChallengeReceived(authContext : AuthenticationContext, challenge : AnyObject?) {
        self.authContext = authContext
        
        guard let appID = challenge?[GoogleAuthenticationManager.GOOGLE_APP_ID_KEY] as? String where appID == GIDSignIn.sharedInstance().clientID
            else{
                authContext.submitAuthenticationFailure([NSLocalizedDescriptionKey:"App Id from server doesn't match the one defined in the .plist file"])
                return
                
        }
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    public func onAuthenticationSuccess(info : AnyObject?){
        authContext = nil
    }
    
    public func onAuthenticationFailure(info : AnyObject?){
        authContext = nil
    }
    
    @objc
    public func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error == nil) {
            let idToken = user.authentication.idToken // Safe to send to the server
            
            do {
                if let unwrappedAuthContext = authContext {
                    try unwrappedAuthContext.submitAuthenticationChallengeAnswer([GoogleAuthenticationManager.ID_TOKEN_KEY: idToken])
                }
            } catch (let errorException){
                authContext?.submitAuthenticationFailure(["error" : "\(errorException)"])
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
         localVC!.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    @objc
    public func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
        localVC!.dismissViewControllerAnimated(true, completion: nil)
    }
  }
