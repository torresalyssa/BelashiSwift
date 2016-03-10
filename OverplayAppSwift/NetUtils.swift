//
//  NetUtils.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/10/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import Foundation

class NetUtils: NSObject {
    
    static func getWifiAddress() -> String? {
        var address : String?
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        
        if getifaddrs(&ifaddr) == 0 {
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let interface = ptr.memory
                let addrFamily = interface.ifa_addr.memory.sa_family
                
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String.fromCString(interface.ifa_name)
                    if name == "en0" {
                        var addr = interface.ifa_addr.memory
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        getnameinfo(&addr, socklen_t(interface.ifa_addr.memory.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                        address = String.fromCString(hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}
