//
//  RegisterViewController.swift
//  ComeOn1
//
//  Created by Antoine roy on 04/10/2015.
//  Copyright © 2015 Antoine roy. All rights reserved.
//

import UIKit
import SwiftHTTP
import ObjectMapper

class RegisterViewController: UIViewController, UITextFieldDelegate {

    var saveFrameBtnLogin: CGRect!
    
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var moveView: UIView!
    
    var loginIfJustRegistered: String?
    var passwordIfJustRegistered: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        print("didAppear")
        //print(btnSignUp.frame)
        animAllView()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func GoToLoginController(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginPage") as! LoginViewController
        vc.loginIfJustRegistered = loginIfJustRegistered
        vc.passwordIfJustRegistered = passwordIfJustRegistered
        vc.saveFrameSignUp = btnSignUp.frame
        vc.firstAnim = false
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    func animAllView() {
        let saveBtnSignUp: CGRect = btnSignUp.frame
        print("btn login: \(saveFrameBtnLogin)\nbtn signUp: \(btnSignUp.frame)")
        btnSignUp.frame = saveFrameBtnLogin
        print("avant anim: \(btnSignUp.frame)")
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: {
            self.btnSignUp.frame = saveBtnSignUp
            }, completion: nil)
    }
    
    @IBAction func SignUp(sender: AnyObject) {
        let params = ["email": emailField.text!, "pseudo": usernameField.text!, "password": passwordField.text!]
        ComeOnAPI.sharedInstance.performRequest(UserRoute.Create(params),
            success: { (json, httpCode) -> Void in
                self.loginIfJustRegistered = self.usernameField.text!
                self.passwordIfJustRegistered = self.passwordField.text!
                
                // Save credentials into device
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(self.loginIfJustRegistered, forKey: "username")
                defaults.setObject(self.passwordIfJustRegistered, forKey: "password")
                defaults.synchronize()
                
                let alertController = UIAlertController(title: "Succès", message: "Le compte a bien été créé.", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            },
            failure: { (json, httpCode) -> Void in
                let error = Mapper<Error>().map(json)
                let alertController = UIAlertController(title: "Erreur", message: error?.error, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("bonjour")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            //let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            let y = -keyboardSize.height + 16
            
            UIView.animateWithDuration(0.3, animations: {
                self.moveView.frame = CGRectMake(0, y, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
                }, completion: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: {
            self.moveView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            }, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        if textField == usernameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}
