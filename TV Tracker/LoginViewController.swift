//
//  LoginViewController.swift
//  TV Tracker
//
//  Created by Atharv Vaish on 6/27/14.
//  Copyright (c) 2014 Atharv Vaish. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, NSURLSessionDataDelegate {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signInButton: UIBarButtonItem!
    @IBOutlet weak var registerButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    
    let apiKey = (UIApplication.sharedApplication().delegate as AppDelegate).apiKey
    private var receivingData = NSMutableData()
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if title == "Sign In" {
            signInButton.enabled = false
            signInButton.title = " "
        } else {
            registerButton.enabled = false
            registerButton.title = " "
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        usernameField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func beginEditing() {
        UIView.animateWithDuration(0.5, animations: {
            if self.title == "Sign In" {
                self.signInButton.enabled = true
                self.signInButton.title = "Sign In"
            } else {
                self.registerButton.enabled = true
                self.registerButton.title = "Register"
            }
        })
    }
    
    @IBAction func endEditing() {
        view.endEditing(false)
    }
    
    @IBAction func signIn(sender: UIBarButtonItem) {
        view.endEditing(false)
        
        let signInData = ["username": usernameField.text,
                          "password": passwordField.text.sha1()]
        
        let url = NSURL(string: apiKey, relativeToURL: NSURL(string: "http://api.trakt.tv/account/test/"))
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var err: AutoreleasingUnsafeMutablePointer<NSError?> = nil
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(signInData, options: nil, error: err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                        delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request)
        task.resume()
    }
    
    @IBAction func register(sender: UIBarButtonItem) {
        view.endEditing(false)
        
        if passwordField.text != confirmPasswordField.text {
            var alert = UIAlertController(title: "Passwords do not match",
                message: "Please make sure you type in your password correctly", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                alert.dismissViewControllerAnimated(true, completion: nil)
                self.passwordField.becomeFirstResponder()
            }))
            presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        let registerData = ["username": usernameField.text,
                            "password": passwordField.text.sha1(),
                               "email": emailField.text]
        
        let url = NSURL(string: apiKey, relativeToURL: NSURL(string: "http://api.trakt.tv/account/create/"))
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var err: AutoreleasingUnsafeMutablePointer<NSError?> = nil
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(registerData, options: nil, error: err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request)
        task.resume()
    }
    
    func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, didReceiveData data: NSData!) {
        receivingData.appendData(data)
    }
    
    func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didCompleteWithError error: NSError!) {
        let receivedData = NSData(data: receivingData)
        receivingData = NSMutableData()
        
        if error {
            var alert = UIAlertController(title: "Could not connect to Trakt",
                                        message: error.localizedDescription, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: { action in
                alert.dismissViewControllerAnimated(true, completion: nil)
                self.signIn(self.signInButton)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true, completion: nil)
            })
        } else {
            var err: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            var response = NSJSONSerialization.JSONObjectWithData(receivedData,
                options: nil, error: err) as Dictionary<String, String>
            
            if title == "Sign In" {
                if response["status"] == "failure" {
                    var alert = UIAlertController(title: "Authentication Failed",
                        message: "You can edit your username/password, or cancel and register instead.",
                        preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Edit", style: .Default, handler: { action in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        self.usernameField.becomeFirstResponder()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        self.navigationController.popViewControllerAnimated(true)
                    }))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                } else {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    
                    defaults.setObject(usernameField.text, forKey: "username")
                    defaults.setObject(passwordField.text.sha1(), forKey: "password")
                    defaults.synchronize()
                    
                    let store = NSUbiquitousKeyValueStore.defaultStore()
                    if store {
                        store.setObject(usernameField.text, forKey: "username")
                        store.setObject(passwordField.text.sha1(), forKey: "password")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            } else {
                if response["status"] == "failure" {
                    var alert = UIAlertController(title: "Registration Failed",
                        message: response["error"]! + ". You can edit or cancel and sign in instead.",
                        preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Edit", style: .Default, handler: { action in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        self.usernameField.becomeFirstResponder()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        self.navigationController.popViewControllerAnimated(true)
                    }))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                } else {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    
                    defaults.setObject(usernameField.text, forKey: "username")
                    defaults.setObject(passwordField.text.sha1(), forKey: "password")
                    defaults.synchronize()
                    
                    let store = NSUbiquitousKeyValueStore.defaultStore()
                    if store {
                        store.setObject(usernameField.text, forKey: "username")
                        store.setObject(passwordField.text.sha1(), forKey: "password")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if title == "Sign In" {
            if textField == usernameField {
                passwordField.becomeFirstResponder()
            } else {
                signIn(signInButton)
            }
        } else {
            if textField == usernameField {
                emailField.becomeFirstResponder()
            } else if textField == emailField {
                passwordField.becomeFirstResponder()
            } else if textField == passwordField {
                confirmPasswordField.becomeFirstResponder()
            } else {
                register(registerButton)
            }
        }
        return true
    }
}
