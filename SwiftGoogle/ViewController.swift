//
//  ViewController.swift
//  SwiftGoogle
//
//  Created by Ilan Klein on 02/02/2016.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        GIDSignIn.sharedInstance().uiDelegate = self
        
        BMSGoogleOAuth.sharedInstance.localVC = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signIn(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
   
    @IBAction func signOut(sender: UIButton) {
        GIDSignIn.sharedInstance().disconnect()
    }
    
}

