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
                    self.authorize(email, password: password, success: Notifications.signInSuccess, fail: Notifications.signInFailure)
                    
                default:
                    self.nc.postNotificationName(Notifications.signInFailure, object: nil, userInfo: ["error": Notifications.noSuchUser])
                }
        }
    }
    
    func signUp(email: String, password: String) {
        Alamofire.request(.GET, self.serverBase + "/user/hasAccount?email=" + email)
            
            .responseJSON{response in
                
                switch response.response!.statusCode {
                    
                case 200...299:
                    self.nc.postNotificationName(Notifications.signUpFailure, object: nil, userInfo: ["error": Notifications.userAlreadyExists])
                    
                default:
                    self.authorize(email, password: password, success: Notifications.signUpSuccess, fail: Notifications.signUpFailure)
                }
        }
    }
    
    func authorize(email: String, password: String, success: String, fail: String) {
    
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
                        self.nc.postNotificationName(success, object: nil)
                        
                    default:
                        print("Got bad status: \(statusCode)")
                        self.nc.postNotificationName(fail, object: nil, userInfo: ["error": Notifications.badStatusCode])
                    }
                
                case .Failure(let error):
                    print(error.localizedDescription)
                    
                    // TODO: find a way to look at response body to find exact error
                    
                    // TODO: find a way to know password requirements to send back to UI
                    
                    switch statusCode {
                        
                    case 400:
                        print("Bad password")
                        self.nc.postNotificationName(fail, object: nil, userInfo: ["error": Notifications.invalidPassword])
                        
                    case 403:
                        print("Wrong password")
                        self.nc.postNotificationName(fail, object: nil, userInfo: ["error": Notifications.wrongPassword])
                        
                    default:
                        print("Unidentified error")
                        self.nc.postNotificationName(fail, object: nil)
                    }
                }
            }
    }
}