//
//  Overplayer.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/8/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit

class OPIE {
    
    var systemName: String
    var location: String
    var ipAddress: String
    var lastHeardFrom: NSDate
    
    // OverplayerCell in the collection view is currently formatted to display an icon
    // image with a 1:1 aspect ratio. Images of a different aspect ratio will look off.
    var icon: UIImage
    
    class var defaultIconImage: UIImage {
        return UIImage(named: "tv_icon.png")!
    }
    
    init() {
        self.systemName = ""
        self.location = ""
        self.ipAddress = ""
        self.lastHeardFrom = NSDate()
        self.icon = OPIE.defaultIconImage
    }
    
    init(name: String, location: String, ipAddress: String, time: NSDate) {
        self.systemName = name
        self.location = location
        self.ipAddress = ipAddress
        self.lastHeardFrom = time
        self.icon = OPIE.defaultIconImage
    }
    
    init(name: String, location: String, ipAddress: String, time: NSDate, iconImage: String) {
        self.systemName = name
        self.location = location
        self.ipAddress = ipAddress
        self.lastHeardFrom = time
        self.icon = UIImage(named: iconImage)!
    }
    
    func getDecachedUrl() -> String {
        let r = arc4random_uniform(100000)
        return String(format: "http://%@/opp/io.overplay.mainframe/app/control/index.html?decache=%ld", self.ipAddress, r)
    }
    
    func description() -> String {
        return "systemName: \(self.systemName) " +
               "location: \(self.location) " +
               "ipAddress: \(self.ipAddress) " +
               "lastHeardFrom: \(self.lastHeardFrom)"
    }
}