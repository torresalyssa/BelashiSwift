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
}

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: SignUpDelegate?
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reEnteredPassword: UITextField!
    
    @IBAction func signUp(sender: UIButton) {
        
        // check email address is valid
        if self.email.text == nil || self.email.text!.isEmpty || validateEmail(self.email.text!) == false {
            
            let alertController = UIAlertController(title: "Email address", message: "Please enter a valid email address.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
            
        // check both passwords are entered
        else if self.password.text == nil || self.reEnteredPassword.text == nil || self.password.text!.isEmpty || self.reEnteredPassword.text!.isEmpty {
            
            let alertController = UIAlertController(title: "Password", message: "Please enter and re-enter a password.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
            
        // check both passwords match
        else if self.password.text != self.reEnteredPassword.text {
            let alertController = UIAlertController(title: "Password", message: "Passwords do not match!", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        // TODO: sign up
        else {
            OCS.sharedInstance.signUp(self.email.text!, password: self.password.text!)
        }
    }
    
    @IBAction func signIn(sender: UIButton) {
        if self.delegate != nil {
            self.delegate?.gotoSignIn()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.email.placeholder = "Email address"
        self.email.delegate = self
        self.password.placeholder = "Password"
        self.password.delegate = self
        self.reEnteredPassword.placeholder = "Re-enter password"
        self.reEnteredPassword.delegate = self
    }
    
    func validateEmail(emailAddr: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluateWithObject(emailAddr)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
