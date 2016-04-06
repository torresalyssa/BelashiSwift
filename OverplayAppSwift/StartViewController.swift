//
//  RegisterViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/30/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit

class StartViewController: UIViewController, SignInDelegate, SignUpDelegate {
    
    @IBOutlet weak var containerView: UIView!
    
    var signInViewController: UIViewController?
    var signUpViewController: UIViewController?
    var activeViewController: UIViewController? {
        didSet {
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check if user is already signed in
        if Account.sharedInstance.password != nil {
            print("Logged in as \(Account.sharedInstance.username!).")
            self.performSegueWithIdentifier("toChooseOverplayer", sender: self)
        }
        
        // set up child views
        self.signInViewController = self.storyboard?.instantiateViewControllerWithIdentifier("signInForm")
        let signInVC = self.signInViewController as! SignInViewController
        signInVC.delegate = self
        
        self.signUpViewController = self.storyboard?.instantiateViewControllerWithIdentifier("signUpForm")
        let signUpVC = self.signUpViewController as! SignUpViewController
        signUpVC.delegate = self
        
        // display sign in form
        self.activeViewController = self.signInViewController
    }
    
    func gotoSignUp() {
        self.activeViewController = self.signUpViewController
    }
    
    func gotoSignIn() {
        self.activeViewController = self.signInViewController
    }
    
    func gotoChooseOverplayer() {
        self.performSegueWithIdentifier("toChooseOverplayer", sender: nil)
    }
    
    func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if inactiveViewController != nil {
            inactiveViewController!.willMoveToParentViewController(nil)
            inactiveViewController!.view.removeFromSuperview()
            inactiveViewController!.removeFromParentViewController()
        }
    }
    
    func updateActiveViewController() {
        if self.activeViewController != nil {
            addChildViewController(self.activeViewController!)
            self.activeViewController!.view.frame = self.containerView.bounds
            self.containerView.addSubview(self.activeViewController!.view)
            self.activeViewController?.didMoveToParentViewController(self)
        }
    }

}
