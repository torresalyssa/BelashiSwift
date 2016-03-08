//
//  ViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit
import Alamofire
import CocoaAsyncSocket

class ChooseOverplayerViewController: UIViewController {

    @IBOutlet var mainStatusLabel: UILabel!
    @IBOutlet var foundUnitsTable: UITableView!
    
    var availableOverplayers: NSMutableArray!
    var sortedOverplayers: NSArray!
    var iphoneIPAddress: NSString!
    var refreshControl: UIRefreshControl!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

