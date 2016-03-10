//
//  FirstViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit

class OverplayerViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var bannerLabel: UILabel!
    @IBOutlet var webView: UIWebView!
    @IBAction func disme(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var op = Overplayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let r = arc4random_uniform(100000)
        
        if self.respondsToSelector(Selector("setAutomaticallyAdjustsScrollViewInsets")) {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.webView.delegate = self
        let url = NSURL(string: String(format: "http://%@/opp/io.overplay.mainframe/app/control/index.html?decache=%ld", self.op.ipAddress, r))
        self.webView.loadRequest(NSURLRequest(URL: url!))
        
        self.bannerLabel.text = self.op.systemName
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
