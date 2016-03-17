//
//  ViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ChooseOverplayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GCDAsyncUdpSocketDelegate {

    @IBOutlet var mainStatusLabel: UILabel!
    @IBOutlet var foundUnitsTable: UITableView!
    
    var availableOverplayers = [Overplayer]()
    var iphoneIPAddress = ""
    var refreshControl: UIRefreshControl!
    var socket: GCDAsyncUdpSocket!
    
    let PORT: UInt16 = 9090
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UDP socket
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())

        do {
            try self.socket.bindToPort(PORT)
        } catch {
            print("Socket failed to bind to port %d", PORT)
        }
        
        do {
            try self.socket.beginReceiving()
        } catch {
            self.socket.close()
            print("Socket failed to begin receiving.")
        }
        
        //
        self.foundUnitsTable.dataSource = self
        self.foundUnitsTable.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: Selector("findOverplayers"), forControlEvents: UIControlEvents.ValueChanged)
        self.foundUnitsTable.addSubview(self.refreshControl)
        
        self.findOverplayers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func findOverplayers() {
        self.refreshControl.beginRefreshing()
        self.availableOverplayers = []
        
        if let address = NetUtils.getWifiAddress() {
            self.mainStatusLabel.text = String(format: "My IP: \(address)")
        } else {
            self.mainStatusLabel.text = "Not on a WiFi Network"
            self.refreshControl.endRefreshing()
        }
        
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("stopRefresh"),userInfo: nil, repeats: false)
    }
    
    func stopRefresh() {
        self.refreshControl.endRefreshing()
    }
    
    func sortByIPAndReload() {
        
        // TODO: sort array by IP
        
        self.foundUnitsTable.reloadData()
    }
    
    
    // MARK: - GCDAsyncUdpSocket
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        
        let toAdd = Overplayer()
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
        
        var addressString : String?
        var sa = sockaddr()
        address.getBytes(&sa, length: sizeof(sockaddr))
        switch (Int32(sa.sa_family)) {
            
        case AF_INET:
            var ip4 = sockaddr_in()
            address.getBytes(&ip4, length: sizeof(sockaddr_in))
            addressString = String(format: "%s", inet_ntoa(ip4.sin_addr))
            
        case AF_INET6:
            // ignore 
            break
            
        default:
            break
        }
        
        if (addressString != nil) {
            
            for op in self.availableOverplayers {
                if op.ipAddress == addressString {
                    op.systemName = toAdd.systemName
                    op.location = toAdd.location
                    self.refreshControl.endRefreshing()
                    self.foundUnitsTable.reloadData()
                    return
                }
            }
            
            toAdd.ipAddress = addressString!
            self.availableOverplayers.append(toAdd)
            self.refreshControl.endRefreshing()
            self.sortByIPAndReload()
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableOverplayers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SimpleTableItem")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "SimpleTableItem")
        }
        
        cell!.textLabel!.text = self.availableOverplayers[indexPath.row].systemName
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toOPControl", sender: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toOPControl") {
            self.refreshControl.endRefreshing()
            let indexPath = self.foundUnitsTable.indexPathForSelectedRow
            let op = self.availableOverplayers[indexPath!.row]
            let ovc:OverplayerViewController = segue.destinationViewController as! OverplayerViewController
            ovc.op = op
        }
    }

}

