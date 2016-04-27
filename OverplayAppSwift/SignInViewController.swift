//
//  LoginViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/28/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit
import JGProgressHUD

protocol SignInDelegate {
    func gotoSignUp()
    func gotoChooseOverplayer()
}

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: SignInDelegate?
    
    let nc = NSNotificationCenter.defaultCenter()
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBAction func signIn(sender: UIButton) {
        
        guard let emailInput = self.email.text else {
            showAlert("Email address", message: "Please enter a valid email address.")
            return
        }
        
        guard let p = self.password.text else {
            showAlert("Password", message: "Please enter a password.")
            return
        }
      
        if validateEmail(emailInput) == false {
            showAlert("Email address", message: "Please enter a valid email address.")
        } else {
            OCS.sharedInstance.signIn(emailInput, password: p)
        }
    }
    
    @IBAction func signUp(sender: UIButton) {
        if let del = self.delegate {
            del.gotoSignUp()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nc.addObserver(self, selector: "signInSuccess", name: Notifications.signInSuccess, object: nil)
        
        self.email.placeholder = "Email address"
        self.email.delegate = self
        self.password.placeholder = "Password"
        self.password.delegate = self
    }
    
    func signInSuccess() {
        Account.sharedInstance.username = self.email.text
        Account.sharedInstance.password = self.password.text
        print("Signed in as \(Account.sharedInstance.username)")
        self.delegate?.gotoChooseOverplayer()
    }
    
    func validateEmail(emailAddr: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluateWithObject(emailAddr)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}