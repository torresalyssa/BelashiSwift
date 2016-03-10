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
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
        // TODO: get iPhone IP address
        
        self.mainStatusLabel.text = "Testing"
        self.availableOverplayers = []
        
        let newOverplayer = Overplayer()
        newOverplayer.ipAddress = "0.0.0.0"
        newOverplayer.systemName = "Test overplayer"
        newOverplayer.location = "a room"
        
        self.availableOverplayers.append(newOverplayer)
        self.refreshControl.endRefreshing()
    }
    
    func sortByIPAndReload() {
        
        // TODO: sort array by IP
        
        self.foundUnitsTable.reloadData()
    }
    
    // MARK: - GCDAsyncUdpSocket
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        
        var overplayerJson: NSDictionary
        do {
            overplayerJson = try NSJSONSerialization.JSONObjectWithData(data, options:[]) as! NSDictionary
        } catch {
            print("Error converting UDP packet to JSON")
        }
        
        let toAdd = Overplayer()
        //toAdd.systemName = overplayerJson["name"]
        //toAdd.location = overplayerJson["location"]
        
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
        
        // TODO: actually do this
        
        cell!.textLabel!.text = "Test"
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toOPControl", sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toOPControl") {
            print("segueing")
            self.refreshControl.endRefreshing()
            let indexPath = self.foundUnitsTable.indexPathForSelectedRow
            let op = self.availableOverplayers[indexPath!.row]
            let ovc:OverplayerViewController = segue.destinationViewController as! OverplayerViewController
            ovc.op = op
        }
    }

}

