//
//  AppSettings.swift
//  A8PhotoOp
//
//  Created by Mitchell Kahn on 3/9/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import Foundation

class AppSettings {
    
    static let sharedInstance = AppSettings()
    
    // MARK: Login
    
    var isLoggedIn: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("isLoggedIn")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "isLoggedIn")
        }
    }
    
    var username: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("username")!
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "username")
        }
    }
    
    // MARK: Languages
    
    var showFrench: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("showFrench")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "showFrench")
        }
    }
    
    var showSpanish: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("showSpanish")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "showSpanish")
        }
    }
    
    var supportedLanguages: [String] {
        get {
            var rval = ["en"]
            if self.showSpanish {
                rval.append("es")
            }
            if self.showFrench {
                rval.append("fr")
            }
            return rval
        }
    }

    // MARK: Privacy Policy
    
    var privacyPolicyHTML: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("privacyPolicyHTML")!
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "privacyPolicyHTML")
        }
    }
    
    var opt1PolicyHTML: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("opt1PolicyHTML")!
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "opt1PolicyHTML")
        }
    }

    var opt2PolicyHTML: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("opt2PolicyHTML")!
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "opt2PolicyHTML")
        }
    }
    
    // MARK:Defaults
    
    func registerDefaults(){
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        prefs.registerDefaults([
            
            "showFrench" :  false,
            "showSpanish" : false,
            "isLoggedIn" : false
            
            ])
    }
    
}

   