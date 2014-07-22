//
//  LoginViewController.swift
//  TV Tracker
//
//  Created by Atharv Vaish on 6/27/14.
//  Copyright (c) 2014 Atharv Vaish. All rights reserved.
//

import UIKit

enum FormState: String, Printable {
    case None = "No Form"
    case SignIn = "Sign In"
    case Register = "Register"
    
    var description: String {
    get {
        return toRaw()
    }
    }
}

class LoginViewController: UIViewController, UITextFieldDelegate, NSURLSessionDataDelegate {
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var logo: UIImageView!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var navTitle: UINavigationItem!
    lazy var usernameField: UITextField = {
        var usernameField = UITextField()
        
        usernameField.placeholder = "username";
        usernameField.alpha = 0
        usernameField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        usernameField.clearButtonMode = .WhileEditing
        usernameField.font = UIFont.systemFontOfSize(14)
        usernameField.autocapitalizationType = .None
        usernameField.autocorrectionType = .No
        usernameField.spellCheckingType = .No
        usernameField.keyboardType = .Default
        usernameField.returnKeyType = .Next
        usernameField.enablesReturnKeyAutomatically = true
        usernameField.delegate = self
        
        return usernameField
    }()
    lazy var emailField: UITextField = {
        var emailField = UITextField()
        
        emailField.placeholder = "email address";
        emailField.alpha = 0
        emailField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        emailField.clearButtonMode = .WhileEditing
        emailField.font = UIFont.systemFontOfSize(14)
        emailField.autocapitalizationType = .None
        emailField.autocorrectionType = .No
        emailField.spellCheckingType = .No
        emailField.keyboardType = .EmailAddress
        emailField.returnKeyType = .Next
        emailField.enablesReturnKeyAutomatically = true
        emailField.delegate = self
        
        return emailField
    }()
    lazy var passwordField: UITextField = {
        var passwordField = UITextField()
        
        passwordField.placeholder = "password";
        passwordField.alpha = 0
        passwordField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        passwordField.clearButtonMode = .WhileEditing
        passwordField.font = UIFont.systemFontOfSize(14)
        passwordField.autocapitalizationType = .None
        passwordField.autocorrectionType = .No
        passwordField.spellCheckingType = .No
        passwordField.keyboardType = .Default
        passwordField.enablesReturnKeyAutomatically = true
        passwordField.secureTextEntry = true
        passwordField.delegate = self
        
        return passwordField
    }()
    lazy var passwordConfirmField: UITextField = {
        var passwordConfirmField = UITextField()
        
        passwordConfirmField.placeholder = "confirm password";
        passwordConfirmField.alpha = 0
        passwordConfirmField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        passwordConfirmField.clearButtonMode = .WhileEditing
        passwordConfirmField.font = UIFont.systemFontOfSize(14)
        passwordConfirmField.autocapitalizationType = .None
        passwordConfirmField.autocorrectionType = .No
        passwordConfirmField.spellCheckingType = .No
        passwordConfirmField.keyboardType = .Default
        passwordConfirmField.returnKeyType = .Go
        passwordConfirmField.enablesReturnKeyAutomatically = true
        passwordConfirmField.secureTextEntry = true
        passwordConfirmField.delegate = self
        
        return passwordConfirmField
    }()
    lazy var backButton: UIButton = {
        var backButton = UIButton.buttonWithType(.System) as UIButton
        
        backButton.setTitle("Back", forState: .Normal)
        backButton.alpha = 0
        
        return backButton
    }()
    lazy var errorLabel: UILabel = {
        var errorLabel = UILabel()
        
        errorLabel.textColor = UIColor.redColor()
        errorLabel.textAlignment = .Center
        errorLabel.alpha = 0
        
        return errorLabel
    }()
    var keyboardOffset: CGFloat = 0
    var centerOffset: CGFloat = 0
    var formState = FormState.None
    var rotating = false
    let apiKey = (UIApplication.sharedApplication().delegate as AppDelegate).apiKey
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func endEditing(sender: UIView) {
        self.view.endEditing(false)
    }
    
    func positionFields() {
        if formState == .SignIn {
            usernameField.frame = CGRect(x: logo.frame.maxX + 15, y: logo.frame.minY + 25, width: 190, height: 30)
            passwordField.frame = CGRect(x: logo.frame.maxX + 15, y: logo.frame.minY + 65, width: 190, height: 30)
            passwordField.returnKeyType = .Go
        } else {
            usernameField.frame = CGRect(x: view.bounds.midX - 145, y: logo.frame.minY + 25, width: 140, height: 30)
            passwordField.frame = CGRect(x: view.bounds.midX - 145, y: logo.frame.minY + 65, width: 140, height: 30)
            emailField.frame = CGRect(x: view.bounds.midX + 5, y: logo.frame.minY + 25, width: 140, height: 30)
            passwordConfirmField.frame = CGRect(x: view.bounds.midX + 5, y: logo.frame.minY + 65, width: 140, height: 30)
            passwordField.returnKeyType = .Next
        }
    }
    
    func createErrorLabelWithMessage(message: String) {
        errorLabel.text = message
        errorLabel.frame = CGRect(x: view.bounds.midX - 145, y: logo.frame.minY + 105, width: 290, height: 30)
        view.addSubview(errorLabel)
        UIView.animateWithDuration(0.5, animations: {
            self.errorLabel.alpha = 100
        })
    }
    
    func removeErrorLabel() {
        errorLabel.alpha = 0
        errorLabel.removeFromSuperview()
    }
    
    func positionBackButton(x: CGFloat, y: CGFloat) {
        self.backButton.frame = CGRect(x: x, y: y, width: 0, height: 0)
        self.backButton.transform = CGAffineTransformIdentity
        self.backButton.sizeToFit()
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection!, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        rotating = true
        
        if formState != .None {
            removeErrorLabel()
            if traitCollection.verticalSizeClass == .Regular {
                if newCollection.verticalSizeClass == .Compact {
                    self.infoLabel.alpha = 0
                    coordinator.animateAlongsideTransition({context in
                        if self.formState == .SignIn {
                            self.logo.transform = CGAffineTransformTranslate(self.logo.transform, (self.view.frame.width - 305) / 2 - self.logo.frame.minX, 0)
                            self.positionFields()
                            self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, self.backButton.frame.minX - self.signInButton.frame.minX, 0)
                            self.positionBackButton(self.signInButton.frame.minX, y: self.signInButton.frame.minY)
                            self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, self.registerButton.frame.maxX - self.signInButton.frame.maxX, 0)
                        } else {
                            self.positionBackButton(self.signInButton.frame.minX, y: self.signInButton.frame.minY)
                        }
                    }, completion: nil)
                }
            } else {
                if newCollection.verticalSizeClass == .Regular {
                    coordinator.animateAlongsideTransition({context in
                        if self.formState == .SignIn {
                            self.logo.transform = CGAffineTransformTranslate(self.logo.transform, 100 + self.infoLabel.frame.minX - self.logo.frame.maxX - 10, 0)
                            self.positionFields()
                            self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, self.backButton.frame.minX - self.signInButton.frame.minX, 0)
                            self.positionBackButton(self.signInButton.frame.minX, y: self.signInButton.frame.minY)
                            self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, self.registerButton.frame.maxX - self.signInButton.frame.maxX, 0)
                            self.infoLabel.alpha = 100
                        } else {
                            self.positionBackButton(self.signInButton.frame.minX, y: self.signInButton.frame.minY)
                            self.infoLabel.alpha = 100
                        }
                    }, completion: nil)
                }
            }
        }
        
        coordinator.animateAlongsideTransition(nil, completion: {context in
            self.rotating = false
        })
    }
    
    func keyboardWasShown(notification: NSNotification) {
        if notification.userInfo {
            removeErrorLabel()
            
            let screenRect = (notification.userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            let windowRect = self.view.window.convertRect(screenRect, fromWindow: nil)
            let viewRect = self.view.convertRect(windowRect, fromView: nil)
            
            let movement = viewRect.minY - self.view.bounds.height
            keyboardOffset = movement
            
            UIView.animateWithDuration(0.5, animations: {
                self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, 0, movement)
                self.registerButton.transform = CGAffineTransformTranslate(self.registerButton.transform, 0, movement)
                self.backButton.transform = CGAffineTransformTranslate(self.backButton.transform, 0, movement)
            }, completion: nil)
            
            if traitCollection.verticalSizeClass == .Regular {
                UIView.animateWithDuration(0.5, animations: {
                    if self.infoLabel.frame.minY + movement < self.logo.frame.maxY + 40 {
                        self.infoLabel.alpha = 0
                    } else {
                        self.infoLabel.transform = CGAffineTransformTranslate(self.infoLabel.transform, 0, movement)
                    }
                }, completion: nil)
            } else {
                let centerMovement = -(viewRect.minY / 2) + 12.5
                centerOffset = centerMovement
                
                UIView.animateWithDuration(0.5, animations: {
                    self.logo.transform = CGAffineTransformTranslate(self.logo.transform, 0, centerMovement)
                    self.positionFields()
                }, completion: nil)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let movement = keyboardOffset
        
        UIView.animateWithDuration(0.5, animations: {
            self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, 0, -movement)
            self.registerButton.transform = CGAffineTransformTranslate(self.registerButton.transform, 0, -movement)
            if !self.rotating {
                self.backButton.transform = CGAffineTransformTranslate(self.backButton.transform, 0, -movement)
            }
        }, completion: nil)
        
        if traitCollection.verticalSizeClass == .Regular && !rotating {
            UIView.animateWithDuration(0.5, animations: {
                if self.infoLabel.alpha == 0 {
                    self.infoLabel.alpha = 100
                } else {
                    self.infoLabel.transform = CGAffineTransformTranslate(self.infoLabel.transform, 0, -movement)
                }
            }, completion: nil)
        } else if (traitCollection.verticalSizeClass == .Compact && !rotating) || (traitCollection.verticalSizeClass == .Regular && rotating) {
            let centerMovement = centerOffset
            
            UIView.animateWithDuration(0.5, animations: {
                self.logo.transform = CGAffineTransformTranslate(self.logo.transform, 0, -centerMovement)
                self.positionFields()
            }, completion: nil)
        }
    }
    
    @IBAction func prepareForm(sender: UIButton) {
        formState = FormState.fromRaw(sender.titleLabel.text)!
        
        positionBackButton(signInButton.frame.minX, y: signInButton.frame.minY)
        backButton.addTarget(self, action: "rollbackForm:", forControlEvents: .TouchUpInside)
        view.addSubview(backButton)
        
        let hideButton = { (button: UIButton) in
            UIView.animateWithDuration(0.5, animations: {
                button.alpha = 0
            }, completion: {
                if $0 {
                    button.hidden = true
                }
            })
        }
        
        formState == .Register ? hideButton(signInButton) : hideButton(registerButton)
        
        if formState == .SignIn {
            if traitCollection.verticalSizeClass == .Regular {
                UIView.animateWithDuration(0.5, animations: {
                    self.logo.transform = CGAffineTransformTranslate(self.logo.transform, -100, 0)
                }, completion: nil)
            } else {
                self.infoLabel.alpha = 0
                UIView.animateWithDuration(0.5, animations: {
                    self.logo.transform = CGAffineTransformTranslate(self.logo.transform, (self.view.frame.width - 305) / 2 - self.logo.frame.minX, 0)
                }, completion: nil)
            }
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.logo.alpha = 0
                if self.traitCollection.verticalSizeClass == .Compact {
                    self.infoLabel.alpha = 0
                }
            }, completion: nil)
        }
        
        positionFields()
        
        if formState == .Register {
            self.view.addSubview(usernameField)
            self.view.addSubview(emailField)
            self.view.addSubview(passwordField)
            self.view.addSubview(passwordConfirmField)
        } else {
            self.view.addSubview(usernameField)
            self.view.addSubview(passwordField)
        }
        
        UIView.animateWithDuration(0.5, delay: 0.5, options: .CurveEaseInOut, animations: {
            self.usernameField.alpha = 100
            self.passwordField.alpha = 100
            self.backButton.alpha = 100
            
            if self.formState == .Register {
                self.emailField.alpha = 100
                self.passwordConfirmField.alpha = 100
            } else {
                self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, self.registerButton.frame.maxX - self.signInButton.frame.maxX, 0)
            }
        }, completion: nil)
        
        if formState == .SignIn {
            signInButton.removeTarget(self, action: "prepareForm:", forControlEvents: .TouchUpInside)
            signInButton.addTarget(self, action: "signIn:", forControlEvents: .TouchUpInside)
        } else {
            registerButton.removeTarget(self, action: "prepareForm:", forControlEvents: .TouchUpInside)
            registerButton.addTarget(self, action: "register:", forControlEvents: .TouchUpInside)
        }
        
        usernameField.becomeFirstResponder()
    }
    
    func rollbackForm(sender: UIButton) {
        backButton.removeTarget(self, action: "rollbackForm:", forControlEvents: .TouchUpInside)
        usernameField.alpha = 0
        passwordField.alpha = 0
        emailField.alpha = 0
        passwordConfirmField.alpha = 0
        backButton.alpha = 0
        
        usernameField.removeFromSuperview()
        passwordField.removeFromSuperview()
        emailField.removeFromSuperview()
        passwordConfirmField.removeFromSuperview()
        backButton.removeFromSuperview()
        removeErrorLabel()
        
        view.endEditing(false)
        
        let showButton = { (button: UIButton) in
            UIView.animateWithDuration(0.5, delay: 0.5, options: .CurveEaseInOut, animations: {
                button.hidden = false
                button.alpha = 100
            }, completion: nil)
        }
        
        formState == .Register ? showButton(signInButton) : showButton(registerButton)
        
        UIView.animateWithDuration(0.5, delay: 0.5, options: .CurveEaseInOut, animations: {
            if self.formState == .SignIn {
                self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, self.backButton.frame.minX - self.signInButton.frame.minX, 0)
            }
        }, completion: nil)
        
        if formState == .SignIn {
            if traitCollection.verticalSizeClass == .Regular {
                UIView.animateWithDuration(0.5, animations: {
                    self.logo.transform = CGAffineTransformTranslate(self.logo.transform, 100, 0)
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.5, animations: {
                    self.logo.transform = CGAffineTransformTranslate(self.logo.transform, self.infoLabel.frame.minX - self.logo.frame.maxX - 18, 0)
                    }, completion: nil)
                UIView.animateWithDuration(0.5, delay: 0.5, options: .CurveEaseInOut, animations: {
                    self.infoLabel.alpha = 100
                    }, completion: nil)
            }
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.logo.alpha = 100
                self.infoLabel.alpha = 100
            }, completion: nil)
        }
        
        if formState == .SignIn {
            signInButton.removeTarget(self, action: "signIn:", forControlEvents: .TouchUpInside)
            signInButton.addTarget(self, action: "prepareForm:", forControlEvents: .TouchUpInside)
        } else {
            registerButton.removeTarget(self, action: "register:", forControlEvents: .TouchUpInside)
            registerButton.addTarget(self, action: "prepareForm:", forControlEvents: .TouchUpInside)
        }
        
        formState = .None
    }
    
    func signIn(sender: UIButton) {
        view.endEditing(false)
        
        let signInData = ["username": usernameField.text,
                          "password": passwordField.text.sha1()]
        
        let url = NSURL(string: apiKey, relativeToURL: NSURL(string: "http://api.trakt.tv/account/test/"))
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var err: AutoreleasingUnsafePointer<NSError?> = nil
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(signInData, options: nil, error: err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                        delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request)
        task.resume()
    }
    
    func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, didReceiveData data: NSData!) {
        var err: AutoreleasingUnsafePointer<NSError?> = nil
        var response = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: err) as Dictionary<String, String>
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if response["status"] == "failure" {
            dispatch_async(dispatch_get_main_queue(), {
                self.createErrorLabelWithMessage("Incorrect username / password.")
            })
        } else if response["status"] == "success" {
            defaults.setObject(usernameField.text, forKey: "username")
            defaults.setObject(passwordField.text.sha1(), forKey: "password")
            defaults.synchronize()
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func register(sender: UIButton) {
        view.endEditing(false)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if textField == usernameField {
            if formState == .Register {
                emailField.becomeFirstResponder()
            } else {
                passwordField.becomeFirstResponder()
            }
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            if formState == .Register {
                passwordConfirmField.becomeFirstResponder()
            } else {
                signIn(signInButton)
            }
        } else if textField == passwordConfirmField {
            register(registerButton)
        }
        return true
    }

}
