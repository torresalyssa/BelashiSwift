//
//  FirstViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit
import Alamofire
import JGProgressHUD

class OverplayerViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var bannerLabel: UILabel!
    @IBOutlet var webView: UIWebView!
    @IBAction func disme(sender: UIButton) {
        self.timer.invalidate()
        self.hud.dismiss()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var op = OPIE()
    var timer = NSTimer()
    var interval = 10  // seconds
    var hud : JGProgressHUD!
    var alamofireManager : Alamofire.Manager?
    var requestTimeout = 5  // seconds

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        self.hud.textLabel.text = "Loading"
        self.hud.userInteractionEnabled = false
        self.hud.showInView(self.view)
        
        let r = arc4random_uniform(100000)
        
        if self.respondsToSelector(Selector("automaticallyAdjustsScrollViewInsets")) {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.webView.delegate = self
        let url = NSURL(string: String(format: "http://%@/opp/io.overplay.mainframe/app/control/index.html?decache=%ld", self.op.ipAddress, r))
        self.webView.loadRequest(NSURLRequest(URL: url!))
        
        self.bannerLabel.text = self.op.location
        
        // Configure request timeout
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForResource = NSTimeInterval(self.requestTimeout)
        self.alamofireManager = Alamofire.Manager(configuration: config)
        
        // Periodically check if overplayer is alive
        self.timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.interval), target: self, selector: Selector("checkOverplayer"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("loaded web view")
        self.hud.dismiss()
    }
    
    func checkOverplayer() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            let url = String(format: "http://%@/opp/io.overplay.mainframe/app/control/index.html", self.op.ipAddress)
            self.alamofireManager!.request(.GET, url)
                
                .responseData { response in
                    print(response.response)
                    print("Overplayer dead: \(response.result.isFailure)")
                    
                    if (response.result.isFailure) {
                        print("Overplayer died")
                        self.timer.invalidate()
                        
                        // run UI stuff on main thread
                        dispatch_async(dispatch_get_main_queue()) {
                            self.hud.dismiss()
            
                            let alertController = UIAlertController(title: "Overplay", message: "It looks like this Overplayer has shut down!", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {alert in self.navigationController?.popViewControllerAnimated(true)}))
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
            }
        }
    }
}
