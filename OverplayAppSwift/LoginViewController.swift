//
//  LoginViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/28/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBAction func login(sender: UIButton) {
        print("Log in pressed")
    }
    
    @IBAction func signUp(sender: UIButton) {
        self.performSegueWithIdentifier("toSignUp", sender: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.email.placeholder = "Email address"
        self.password.placeholder = "Password"
    }
}