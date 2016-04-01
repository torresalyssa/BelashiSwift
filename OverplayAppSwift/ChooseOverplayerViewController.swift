//
//  ViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit

class ChooseOverplayerViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    
    @IBOutlet weak var mainStatusLabel: UILabel!
    @IBOutlet var overplayerCollection : UICollectionView!
    
    let nc = NSNotificationCenter.defaultCenter()
    var availableOPIEs = [OPIE]()
    var iphoneIPAddress = ""
    var refreshControl : UIRefreshControl!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        
        // Register for OPIE notifications
        nc.addObserver(self, selector: "newOPIE", name: Notifications.newOPIE, object: nil)
        nc.addObserver(self, selector: "opieSocketError", name: Notifications.OPIESocketError, object: nil)
        
        // Setup collection view
        self.overplayerCollection.dataSource = self
        self.overplayerCollection.delegate = self
        self.overplayerCollection.allowsMultipleSelection = false
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: Selector("findOverplayers"), forControlEvents: UIControlEvents.ValueChanged)
        self.overplayerCollection.addSubview(self.refreshControl)
        self.overplayerCollection.alwaysBounceVertical = true
        
        // For testing
        if let address = NetUtils.getWifiAddress() {
            let op1 = OPIE(name: "Overplayer", location: "AmstelBright", ipAddress: address)
            self.availableOPIEs.append(op1)
        }
        
        let op2 = OPIE(name: "Overplayer", location: "Pool Table", ipAddress: "128.0.5.9")
        self.availableOPIEs.append(op2)
        
        let op3 = OPIE(name: "Overplayer", location: "Back Room", ipAddress: "127.2.5.9")
        self.availableOPIEs.append(op3)
        
        let op4 = OPIE(name: "Overplayer", location: "Somewhere", ipAddress: "128.10.5.9")
        self.availableOPIEs.append(op4)
        
        let op5 = OPIE(name: "Overplayer", location: "Here", ipAddress: "128.10.6.9")
        self.availableOPIEs.append(op5)
        
        let op6 = OPIE(name: "Overplayer", location: "There", ipAddress: "128.23.5.9")
        self.availableOPIEs.append(op6)
        
        self.findOverplayers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newOPIE() {
        self.refreshControl.endRefreshing()
        
        //self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        // for testing...
        self.availableOPIEs.appendContentsOf(OPIEBeaconListener.sharedInstance.opies)
        
        self.sortByIPAndReload()
    }
    
    func opieSocketError() {
        let alertController = UIAlertController(title: "OPIE Locator", message: "There was an error locating OPIEs.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func findOverplayers() {
        self.refreshControl.beginRefreshing()
        
        if let address = NetUtils.getWifiAddress() {
            self.mainStatusLabel.text = String(format: "My IP: \(address)")
        } else {
            self.mainStatusLabel.text = "Not on a WiFi Network"
            self.refreshControl.endRefreshing()
        }
        
        // Stops the spinner if we have seen no UDP packets in 10s
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("stopRefresh"), userInfo: nil, repeats: false)
    }
    
    func stopRefresh() {
        self.sortByIPAndReload()
        self.refreshControl.endRefreshing()
    }
    
    func sortByIPAndReload() {
        self.availableOPIEs.sortInPlace {
            (a : OPIE, b : OPIE) -> Bool in
            let comp = a.ipAddress.compare(b.ipAddress, options: NSStringCompareOptions.NumericSearch)
            if comp == NSComparisonResult.OrderedAscending {
                return true
            } else {
                return false
            }
        }
        self.overplayerCollection.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.availableOPIEs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : OverplayerCell = collectionView.dequeueReusableCellWithReuseIdentifier("DefaultOverplayerCell", forIndexPath: indexPath) as! OverplayerCell
        
        cell.image.image = self.availableOPIEs[indexPath.row].icon
        cell.name.text = self.availableOPIEs[indexPath.row].location
        cell.ipAddress.text = self.availableOPIEs[indexPath.row].ipAddress
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toOPControl", sender: indexPath)
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.refreshControl.endRefreshing()
        
        if (segue.identifier == "toOPControl" && sender != nil) {
            let indexPath: NSIndexPath = sender as! NSIndexPath
            let op = self.availableOPIEs[indexPath.row]
            let ovc : OverplayerViewController = segue.destinationViewController as! OverplayerViewController
            ovc.op = op
        }
    }

}

