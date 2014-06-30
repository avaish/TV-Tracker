//
//  LoginViewController.swift
//  TV Tracker
//
//  Created by Atharv Vaish on 6/27/14.
//  Copyright (c) 2014 Atharv Vaish. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var infoLabel: UILabel
    @IBOutlet var logo: UIImageView
    @IBOutlet var signInButton: UIButton
    @IBOutlet var registerButton: UIButton
    @lazy var usernameField: UITextField = {
        var usernameField = UITextField()
        
        usernameField.placeholder = "username";
        usernameField.alpha = 0
        usernameField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        usernameField.clearButtonMode = UITextFieldViewMode.WhileEditing
        usernameField.font = UIFont.systemFontOfSize(14)
        usernameField.autocapitalizationType = UITextAutocapitalizationType.None
        usernameField.autocorrectionType = UITextAutocorrectionType.No
        usernameField.spellCheckingType = UITextSpellCheckingType.No
        usernameField.keyboardType = UIKeyboardType.Default
        usernameField.returnKeyType = UIReturnKeyType.Next
        usernameField.enablesReturnKeyAutomatically = true
        usernameField.delegate = self
        
        return usernameField
    }()
    @lazy var passwordField: UITextField = {
        var passwordField = UITextField()
        
        passwordField.placeholder = "password";
        passwordField.alpha = 0
        passwordField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        passwordField.clearButtonMode = UITextFieldViewMode.WhileEditing
        passwordField.font = UIFont.systemFontOfSize(14)
        passwordField.autocapitalizationType = UITextAutocapitalizationType.None
        passwordField.autocorrectionType = UITextAutocorrectionType.No
        passwordField.spellCheckingType = UITextSpellCheckingType.No
        passwordField.keyboardType = UIKeyboardType.Default
        passwordField.returnKeyType = UIReturnKeyType.Go
        passwordField.enablesReturnKeyAutomatically = true
        passwordField.secureTextEntry = true
        passwordField.delegate = self
        
        return passwordField
    }()
    @lazy var backButton: UIButton = {
        var backButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        
        backButton.setTitle("Back", forState: UIControlState.Normal)
        backButton.alpha = 0
        
        return backButton
    }()
    var keyboardOffset: CGFloat = 0
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func endEditing(sender: UIView) {
        self.view.endEditing(false)
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        if notification.userInfo == nil {
            return
        }
        let screenRect = (notification.userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        let windowRect = self.view.window.convertRect(screenRect, fromWindow: nil)
        let viewRect = self.view.convertRect(windowRect, fromView: nil)
        
        let movement = viewRect.minY - self.view.bounds.height
        keyboardOffset = movement
        
        UIView.animateWithDuration(0.5, animations: {
            self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, 0, movement)
            self.registerButton.transform = CGAffineTransformTranslate(self.registerButton.transform, 0, movement)
            self.backButton.transform = CGAffineTransformTranslate(self.backButton.transform, 0, movement)
            if self.infoLabel.frame.minY + movement < self.logo.frame.maxY + 40 {
                self.infoLabel.alpha = 0
            } else {
                self.infoLabel.transform = CGAffineTransformTranslate(self.infoLabel.transform, 0, movement)
            }
        }, completion: nil)
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let movement = keyboardOffset
        
        UIView.animateWithDuration(0.5, animations: {
            self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, 0, -movement)
            self.registerButton.transform = CGAffineTransformTranslate(self.registerButton.transform, 0, -movement)
            self.backButton.transform = CGAffineTransformTranslate(self.backButton.transform, 0, -movement)
            if self.infoLabel.alpha == 0 {
                self.infoLabel.alpha = 100
            } else {
                self.infoLabel.transform = CGAffineTransformTranslate(self.infoLabel.transform, 0, -movement)
            }
        }, completion: nil)
    }
    
    @IBAction func prepareSignIn(sender: UIButton) {
        backButton.frame = CGRect(x: signInButton.frame.minX, y: signInButton.frame.minY, width: 0, height: 0)
        backButton.addTarget(self, action: "rollbackSignIn:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.sizeToFit()
        
        if backButton.hidden {
            backButton.hidden = false
        } else {
            view.addSubview(backButton)
        }
        
        UIView.animateWithDuration(0.5, animations: {
            self.registerButton.alpha = 0
            self.logo.transform = CGAffineTransformTranslate(self.logo.transform, -100, 0)
        }, completion: {
            if $0 {
                self.registerButton.hidden = true
            }
        })
        
        usernameField.frame = CGRect(x: self.logo.frame.maxX + 10, y: self.logo.frame.minY + 25, width: 195, height: 30)
        passwordField.frame = CGRect(x: self.logo.frame.maxX + 10, y: self.logo.frame.minY + 65, width: 195, height: 30)
        
        if usernameField.hidden {
            usernameField.hidden = false
            passwordField.hidden = false
        } else {
            self.view.addSubview(usernameField)
            self.view.addSubview(passwordField)
        }
        
        UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.usernameField.alpha = 100
            self.passwordField.alpha = 100
            self.backButton.alpha = 100
            
            self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, self.registerButton.frame.maxX - self.signInButton.frame.maxX, 0)
        }, completion: nil)
        
        usernameField.becomeFirstResponder()
    }
    
    func rollbackSignIn(sender: UIButton) {
        UIView.animateWithDuration(0.5, animations: {
            self.usernameField.alpha = 0
            self.passwordField.alpha = 0
            self.backButton.alpha = 0
        }, completion: {
            if $0 {
                self.usernameField.hidden = true
                self.passwordField.hidden = true
                self.backButton.hidden = true
                
                self.registerButton.hidden = false
            }
        })
        UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.registerButton.alpha = 100
            self.logo.transform = CGAffineTransformTranslate(self.logo.transform, 100, 0)
            self.signInButton.transform = CGAffineTransformTranslate(self.signInButton.transform, self.backButton.frame.minX - self.signInButton.frame.minX, 0)
        }, completion: nil)
        
        view.endEditing(false)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if textField == self.usernameField {
            self.passwordField.becomeFirstResponder()
        }
        return true
    }

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
