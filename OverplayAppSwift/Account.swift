//
//  AppSettings.swift
//  A8PhotoOp
//
//  Created by Mitchell Kahn on 3/9/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import Foundation

class Account {
    
    static let sharedInstance = Account()
    
    var username: String? {
        get {
            if let u = NSUserDefaults.standardUserDefaults().stringForKey("username") {
                return u
            } else {
                return nil
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "username")
        }
    }
    
    var password: String? {
        get {
            if let p = NSUserDefaults.standardUserDefaults().stringForKey("password") {
                return p
            } else {
                return nil
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "password")
        }
    }
    
    var launchedBefore: Bool? {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "launchedBefore")
        }
    }
}

   