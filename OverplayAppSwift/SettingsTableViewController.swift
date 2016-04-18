//
//  SettingsTableViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 4/18/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBAction func signOut(sender: AnyObject) {
        Account.sharedInstance.username = nil
        Account.sharedInstance.password = nil
        self.performSegueWithIdentifier("settingsToStart", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 3
        default:
            print("Fix tableView numberOfRowsInSection!")
            return -1
        }
    }


    /*
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) { }
    */

}
