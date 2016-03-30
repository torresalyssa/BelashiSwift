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
    
    var username: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("username")!
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "username")
        }
    }
    
    var password: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("password")!
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "password")
        }
    }
    
    init() {
        username = ""
        password = ""
    }
}

   