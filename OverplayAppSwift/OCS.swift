//
//  OCS.swift
//  OverplayAppSwift
//  Overplay Cloud System
//
//  Created by Alyssa Torres on 3/30/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import Foundation
import Alamofire

class OCS {
    
    let serverBase = "http://104.236.161.95:1337"
    
    static let sharedInstance = OCS()
    
    let nc = NSNotificationCenter.defaultCenter()
    
    func signIn(email: String, password: String) {
        
        Alamofire.request(.GET, self.serverBase + "/user/hasAccount?email=" + email)
            .responseJSON{response in
                switch response.response!.statusCode {
                case 200...299:
                    print("User found")
                    self.authorize(email, password: password)
                default:
                    print("User not found")
                    self.nc.postNotificationName(Notifications.signInFailure, object: nil, userInfo: ["error": Notifications.noSuchUser])
                }
        }
    }
    
    func authorize(email: String, password: String) {
    
        let params = ["email": email, "password": password]
        
        Alamofire.request(.POST, self.serverBase + "/auth/login", parameters: params)
            .validate()
            .responseJSON{response in
                
                let statusCode = response.response!.statusCode
                
                switch response.result {
            
                case .Success:
            
                    switch statusCode {
            
                    case 200...299:
                        print("Got good status: \(statusCode)")
                        self.nc.postNotificationName(Notifications.signInSuccess, object: nil)
                        
                    default:
                        print("Got bad status: \(statusCode)")
                        self.nc.postNotificationName(Notifications.signInFailure, object: nil, userInfo: ["error": Notifications.badStatusCode])
                    }
                
                case .Failure(let error):
                    print(error.localizedDescription)
                    
                    // TODO: find a way to look at response body to find exact error
                    
                    // TODO: find a way to know password requirements to send back to UI
                    
                    switch statusCode {
                        
                    case 400:
                        print("Bad password")
                        
                    case 403:
                        print("Wrong password")
                        
                    default:
                        print("Unidentified error")
                    }
                    
                    self.nc.postNotificationName(Notifications.signInFailure, object: nil)
                }
            }
    }
    
    func signUp(email: String, password: String) {
        print("OCS signing up for \(email)")
    }
}