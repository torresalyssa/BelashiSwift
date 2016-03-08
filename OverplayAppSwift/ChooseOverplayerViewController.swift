//
//  ViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit

class ChooseOverplayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var mainStatusLabel: UILabel!
    @IBOutlet var foundUnitsTable: UITableView!
    
    var availableOverplayers = [Overplayer]()
    var iphoneIPAddress = ""
    var refreshControl: UIRefreshControl!
    //var socket: GCDAsyncUdpSocket
    
    let PORT = 9090
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        //var error: NSError?
        //self.socket.bindToPort(PORT, error: &error)
        //self.socket.beginReceiving(&error)
        
        self.foundUnitsTable.dataSource = self
        self.foundUnitsTable.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "findOverplayers:", forControlEvents: UIControlEvents.ValueChanged)
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
    }
    
    func sortByIPAndReload() {
        
        // TODO: sort array by IP
        
        self.foundUnitsTable.reloadData()
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
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toOPControl", sender: nil)
    }
    
    
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

