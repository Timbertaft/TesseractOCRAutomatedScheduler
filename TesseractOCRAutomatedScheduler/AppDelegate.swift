//
//  AppDelegate.swift
//  TesseractOCRAutomatedScheduler
//
//  Created by Mihai Pocse on 4/15/18.
//  Copyright © 2018 Mihai Pocse. All rights reserved.
//

/* In order to have full functionality, URL Type of Reverse Client ID from Google.plist has been set.  Additionally, Bitcode has been disabled on all frameworks and classes.  Frameworks were added under the project settings for Tesseract and GoogleAPIClinetForRest (Google Calendar), and project targets are set to use the C++ decompiler to avoid errors when attempting to use Tesseract.  Plist has authorization settings for camera and photo picker.  App icon set for functionality with Iphones, Ipads, and the Apple App Store. */

//Importing CocoaPod dependencies

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST


@UIApplicationMain

/* All code in AppDelegate class exists for providing Google Sign-In with necessary clientIDs and keys for authorizing access to the Google platform and related applications. */

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        // Initialize Google sign-in.
        GIDSignIn.sharedInstance().clientID = "937626467274-1757gns5l0grv671tvn88vr2g8isaa3u.apps.googleusercontent.com"
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    
    
}

