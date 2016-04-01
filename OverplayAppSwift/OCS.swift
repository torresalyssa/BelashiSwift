//
//  OCS.swift
//  OverplayAppSwift
//  Overplay Cloud System
//
//  Created by Alyssa Torres on 3/30/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import Foundation

class OCS {
    
    static let sharedInstance = OCS()
    
    func signIn(username: String, password: String) -> Bool {
        print("OCS signing in")
        return true
    }
    
    func signUp(username: String, password: String) {
        print("OCS signing up for \(username)")
    }
}