//
//  Overplayer.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/8/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import Foundation

class Overplayer {
    
    var systemName : String
    var location : String
    var ipAddress : String
    
    init() {
        self.systemName = ""
        self.location = ""
        self.ipAddress = ""
    }
    
    init(name: String, location: String, ipAddress: String) {
        self.systemName = name
        self.location = location
        self.ipAddress = ipAddress
    }
}