//
//  ViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit
import JGProgressHUD

class ChooseOverplayerViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    
    @IBOutlet weak var mainStatusLabel: UILabel!
    @IBOutlet var overplayerCollection : UICollectionView!
    @IBAction func gotoSettings(sender: AnyObject) {
        self.performSegueWithIdentifier("toSettings", sender: nil)
    }
    
    let nc = NSNotificationCenter.defaultCenter()
    var refreshControl : UIRefreshControl!
    var refreshing = true
    var hud: JGProgressHUD!
    
    var availableOPIEs = [OPIE]()
    var iphoneIPAddress = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display hud
        self.hud = JGProgressHUD(style: JGProgressHUDStyle.Light)
        self.hud.textLabel.text = "Searching..."
        self.hud.userInteractionEnabled = false
        self.hud.showInView(self.view)

        // Register for OPIE notifications
        nc.addObserver(self, selector: "newOPIE", name: Notifications.newOPIE, object: nil)
        nc.addObserver(self, selector: "OPIESocketError", name: Notifications.OPIESocketError, object: nil)
        nc.addObserver(self, selector: "droppedOPIE", name: Notifications.droppedOPIE, object: nil)
        
        // Setup collection view
        self.overplayerCollection.dataSource = self
        self.overplayerCollection.delegate = self
        self.overplayerCollection.allowsMultipleSelection = false
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: Selector("findOverplayers"), forControlEvents: UIControlEvents.ValueChanged)
        self.overplayerCollection.addSubview(self.refreshControl)
        self.overplayerCollection.alwaysBounceVertical = true
        
        self.findOverplayers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newOPIE() {
        //print("New OPIE")
        self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        self.stopRefresh()
    }
    
    func droppedOPIE() {
        print("Dropped OPIE")
        self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        self.stopRefresh()
    }
    
    func OPIESocketError() {
        self.refreshControl.endRefreshing()
        self.hud.dismiss()
        
        let alertController = UIAlertController(title: "OPIE Locator", message: "There was an error locating OPIEs.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func findOverplayers() {
        self.refreshing = true
        
        if let address = NetUtils.getWifiAddress() {
            self.mainStatusLabel.text = String(format: "My IP: \(address)")
            
            // For testing
            //let op1 = OPIE(name: "Overplayer", location: "AmstelBright", ipAddress: address, time: NSDate())
            //self.availableOPIEs.append(op1)
            
        } else {
            self.mainStatusLabel.text = "Not on a WiFi Network"
            self.refreshControl.endRefreshing()
        }
        
        self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        
        // Stops the spinner if we have seen no added/dropped OPIEs in 5s
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("stopRefresh"), userInfo: nil, repeats: false)
    }
    
    func stopRefresh() {
        self.refreshing = false
        self.hud.dismiss()
        self.refreshControl.endRefreshing()
        self.sortByIPAndReload()
    }
    
    func sortByIPAndReload() {
        if self.availableOPIEs.count > 1 {
            self.availableOPIEs.sortInPlace {
                (a : OPIE, b : OPIE) -> Bool in
                let comp = a.ipAddress.compare(b.ipAddress, options: NSStringCompareOptions.NumericSearch)
                if comp == NSComparisonResult.OrderedAscending {
                    return true
                } else {
                    return false
                }
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
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerView", forIndexPath: indexPath)
            
            if self.availableOPIEs.count == 0 && !self.refreshing {
                headerView.hidden = false
            } else {
                headerView.hidden = true
            }
            return headerView
            
        default:
            assert(false, "Unexpected element kind in OPIE collection view.")
        }
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

