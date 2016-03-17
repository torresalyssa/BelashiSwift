//
//  ViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ChooseOverplayerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GCDAsyncUdpSocketDelegate {

    @IBOutlet var mainStatusLabel: UILabel!
    @IBOutlet var overplayerCollection: UICollectionView!
    
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
        
        // Setup collection view
        self.overplayerCollection.dataSource = self
        self.overplayerCollection.delegate = self
        self.overplayerCollection.allowsMultipleSelection = false
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: Selector("findOverplayers"), forControlEvents: UIControlEvents.ValueChanged)
        self.overplayerCollection.addSubview(self.refreshControl)
        self.overplayerCollection.alwaysBounceVertical = true
        
        // For testing
        let op1 = Overplayer()
        op1.ipAddress = "127.34.5.9"
        op1.systemName = "Overplayer"
        op1.location = "Bar"
        self.availableOverplayers.append(op1)
        
        let op2 = Overplayer()
        op2.ipAddress = "128.0.5.9"
        op2.systemName = "Overplayer"
        op2.location = "Pool Table"
        self.availableOverplayers.append(op2)
        
        let op3 = Overplayer()
        op3.ipAddress = "127.2.5.9"
        op3.systemName = "Overplayer"
        op3.location = "Back Room"
        self.availableOverplayers.append(op3)
        
        self.findOverplayers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func findOverplayers() {
        self.refreshControl.beginRefreshing()
        
        // Took this out for testing purposes. Add back in!
        //self.availableOverplayers = []
        
        if let address = NetUtils.getWifiAddress() {
            self.mainStatusLabel.text = String(format: "My IP: \(address)")
        } else {
            self.mainStatusLabel.text = "Not on a WiFi Network"
            self.refreshControl.endRefreshing()
        }
        
        // This stops the spinner if we have seen no UDP packets in 10s, and also clears the list of overplayers.
        // May need to adjust wait time depending on how often overplayers broadcast.
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("stopRefresh"), userInfo: nil, repeats: false)
    }
    
    func stopRefresh() {
        self.sortByIPAndReload()
        self.refreshControl.endRefreshing()
    }
    
    func sortByIPAndReload() {
        self.availableOverplayers.sortInPlace {
            (a : Overplayer, b : Overplayer) -> Bool in
            
            let comp = a.ipAddress.compare(b.ipAddress, options: NSStringCompareOptions.NumericSearch)
            if comp == NSComparisonResult.OrderedAscending {
                return true
            } else {
                return false
            }
        }
        self.overplayerCollection.reloadData()
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
        
        if let ipAddress = NetUtils.getIPAddress(address) {
            
            for op in self.availableOverplayers {
                if op.ipAddress == ipAddress {
                    op.systemName = toAdd.systemName
                    op.location = toAdd.location
                    self.refreshControl.endRefreshing()
                    self.overplayerCollection.reloadData()
                    return
                }
            }
            toAdd.ipAddress = ipAddress
            self.availableOverplayers.append(toAdd)
            self.refreshControl.endRefreshing()
            self.sortByIPAndReload()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((UIScreen.mainScreen().bounds.width-30)/2, 162)
    }*/
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.availableOverplayers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: OverplayerCell = collectionView.dequeueReusableCellWithReuseIdentifier("DefaultOverplayerCell", forIndexPath: indexPath) as! OverplayerCell
        
        cell.image.image = UIImage(named: "tv_icon.png")
        cell.name.text = self.availableOverplayers[indexPath.row].location
        cell.ipAddress.text = self.availableOverplayers[indexPath.row].ipAddress
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toOPControl", sender: indexPath)
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toOPControl" && sender != nil) {
            self.refreshControl.endRefreshing()
            let indexPath: NSIndexPath = sender as! NSIndexPath
            let op = self.availableOverplayers[indexPath.row]
            let ovc:OverplayerViewController = segue.destinationViewController as! OverplayerViewController
            ovc.op = op
        }
    }

}

