//
//  OPIEBeaconListener.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/31/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import CocoaAsyncSocket

class OPIEBeaconListener: GCDAsyncUdpSocketDelegate {
    
    static let sharedInstance = OPIEBeaconListener()

    let PORT: UInt16 = 9090
    private var socket: GCDAsyncUdpSocket!
    let nc = NSNotificationCenter.defaultCenter()
    var opies = [OPIE]()
    
    // TODO: Drop OPIE off list and post notification if we haven't heard from him
    
    private init() {
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_global_queue(QOS_CLASS_UTILITY, 0))
        
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
        } catch {
            print("Error reading UDP JSON.")
            return
        }
        
        if let ipAddress = NetUtils.getIPAddress(address) {
            
            for op in self.opies {
                if op.ipAddress == ipAddress {
                    op.systemName = toAdd.systemName
                    op.location = toAdd.location
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
