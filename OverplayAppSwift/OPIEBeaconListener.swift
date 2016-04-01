//
//  OPIEBeaconListener.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/31/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import CocoaAsyncSocket

class OPIEBeaconListener: NSObject, GCDAsyncUdpSocketDelegate {
    
    static let sharedInstance = OPIEBeaconListener()

    let PORT: UInt16 = 9090
    let timeBeforeDrop: Double = 10  // max time (in seconds) that can elapse between
                                     // OPIE broadcasts before the OPIE is dropped
    
    private var socket: GCDAsyncUdpSocket!
    let nc = NSNotificationCenter.defaultCenter()
    var opies = [OPIE]()
    
    private override init() {
        super.init()
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try self.socket.bindToPort(PORT)
        } catch {
            print("ERROR: OPIE socket failed to bind to port %d", PORT)
            nc.postNotificationName(Notifications.OPIESocketError, object: nil)
        }
        
        do {
            try self.socket.beginReceiving()
        } catch {
            self.socket.close()
            print("ERROR: OPIE socket failed to begin receiving.")
            nc.postNotificationName(Notifications.OPIESocketError, object: nil)
        }
        
        NSTimer.scheduledTimerWithTimeInterval(timeBeforeDrop, target: self, selector: "checkOPIEBeaconTimes", userInfo: nil, repeats: true)
    }
    
    func checkOPIEBeaconTimes() {
        let currentOpies = self.opies
        self.opies = []
        
        for op in currentOpies {
            if let lastHeard = op.lastHeardFrom {
                let elapsedTime = NSDate().timeIntervalSinceDate(lastHeard)
                print("\(elapsedTime)")
                if  elapsedTime < timeBeforeDrop {
                    self.opies.append(op)
                } else {
                    nc.postNotificationName(Notifications.droppedOPIE, object: nil)
                }
            } else {
                nc.postNotificationName(Notifications.droppedOPIE, object: nil)
            }
        }
        
        for op in self.opies {
            print(op.description())
        }
    }
    
    func clearOPIEs() {
        self.opies = []
    }
    
    // MARK: - GCDAsyncUdpSocket
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        
        let toAdd = OPIE()
        
        do {
            let overplayerJson = try NSJSONSerialization.JSONObjectWithData(data, options:[])
            if let name = overplayerJson["name"] as? String {
                toAdd.systemName = name
            }
            if let location = overplayerJson["location"] as? String {
                toAdd.location = location
            }
            toAdd.lastHeardFrom = NSDate()
            
        } catch {
            print("Error reading UDP JSON.")
            return
        }
        
        if let ipAddress = NetUtils.getIPAddress(address) {
            
            for op in self.opies {
                
                // uncomment when not testing
                /*if op.ipAddress == ipAddress {
                    op.systemName = toAdd.systemName
                    op.location = toAdd.location
                    op.lastHeardFrom = NSDate()
                    nc.postNotificationName(Notifications.newOPIE, object: nil)
                    return
                }*/
                
                // comment out when not testing
                if op.systemName == toAdd.systemName {
                    op.systemName = toAdd.systemName
                    op.location = toAdd.location
                    op.lastHeardFrom = NSDate()
                    nc.postNotificationName(Notifications.newOPIE, object: nil)
                    return
                }
            }
            
            toAdd.ipAddress = ipAddress
            self.opies.append(toAdd)
            nc.postNotificationName(Notifications.newOPIE, object: nil)
        }
    }
}
