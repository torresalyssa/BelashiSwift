//
//  SignUpViewController.swift
//  OverplayAppSwift
//
//  Created by Alyssa Torres on 3/28/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit

protocol SignUpDelegate {
    func gotoSignIn()
    func gotoChooseOverplayer()
}

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: SignUpDelegate?
    
    let nc = NSNotificationCenter.defaultCenter()
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reEnteredPassword: UITextField!
    
    @IBAction func signUp(sender: UIButton) {
        
        guard let emailInput = self.email.text else {
            showAlert("Email address", message: "Please enter a valid email address.")
            return
        }
        
        guard let p1 = self.password.text else {
            showAlert("Password", message: "Please enter and re-enter a password.")
            return
        }
        
        guard let p2 = self.reEnteredPassword.text else {
            showAlert("Password", message: "Please enter and re-enter a password.")
            return
        }
        
        if p1 != p2 {
            showAlert("Password", message: "Passwords do not match!")
        } else if validateEmail(emailInput) == false {
            showAlert("Email address", message: "Please enter a valid email address.")
        } else {
            OCS.sharedInstance.signUp(emailInput, password: p1)
        }
    }
    
    @IBAction func signIn(sender: UIButton) {
        if let del = self.delegate {
            del.gotoSignIn()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nc.addObserver(self, selector: "signUpSuccess", name: Notifications.signUpSuccess, object: nil)
        
        self.email.placeholder = "Email address"
        self.email.delegate = self
        self.password.placeholder = "Password"
        self.password.delegate = self
        self.reEnteredPassword.placeholder = "Re-enter password"
        self.reEnteredPassword.delegate = self
    }
    
    func signUpSuccess() {
        Account.sharedInstance.username = self.email.text
        Account.sharedInstance.password = self.password.text
        print("Signed up and signed in as \(Account.sharedInstance.username)")
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
