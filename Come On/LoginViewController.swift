//
//  LoginViewController.swift
//  ComeOn1
//
//  Created by Antoine roy on 23/09/2015.
//  Copyright © 2015 Antoine roy. All rights reserved.
//

import UIKit
import ObjectMapper

class LoginViewController: UIViewController, UITextFieldDelegate {
  
  var saveFrameSignUp: CGRect!
  var firstAnim: Bool = true
  @IBOutlet var btnLogin: UIButton!
  @IBOutlet var loginTextfield: UITextField!
  @IBOutlet var pwdTextfield: UITextField!
  @IBOutlet var moveView: UIView!
  @IBOutlet var btnForgotPwd: UIButton!
    
    var loginIfJustRegistered: String?
    var passwordIfJustRegistered: String?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    print("hello boys")
    self.loginTextfield.delegate = self
    self.pwdTextfield.delegate = self
    print(UIScreen.mainScreen().bounds)
    
    if let log = loginIfJustRegistered, let pwd = passwordIfJustRegistered {
        loginTextfield.text = log
        pwdTextfield.text = pwd
    }
    
    restoreCredentialsIfSaved()
  }
  
  override func viewWillAppear(animated: Bool) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    print("hey: \(firstAnim)")
    if firstAnim == false {
      secondAnimBtnLogin()
    }
    
  }
    
    private func saveCredentials(login: String, password: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(login, forKey: "login")
        defaults.setObject(password, forKey: "password")
    }
    
    private func restoreCredentialsIfSaved() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let log = defaults.stringForKey("login"),
            let pwd = defaults.stringForKey("password") {
            loginTextfield.text = log
            pwdTextfield.text = pwd
        }
    }
  
  @IBAction func connect(sender: AnyObject) {
    let params = ["login": loginTextfield.text!, "password": pwdTextfield.text!]
//    let params = ["login": "test4242", "password": "test4242"]
    ComeOnAPI.sharedInstance.performRequest(AuthRoute.Create(params),
      success: { (json, httpCode) -> Void in
        if let auth = Mapper<Auth>().map(json) {
          ComeOnAPI.sharedInstance.saveCreditentials(auth)
          
            // Save credentials into device
            self.saveCredentials(self.loginTextfield.text!, password: self.pwdTextfield.text!)
            
          self.performSegueWithIdentifier("segueHomeViewController", sender: nil)
        }
      },
      failure: { (json, httpCode) -> Void in
        let error = Mapper<Error>().map(json)
        let alertController = UIAlertController(title: "Erreur", message: error?.error, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
      })
  }
  
  @IBAction func ForgotPassword(sender: AnyObject) {
    // Create the alert controller
    let alertController = UIAlertController(title: "Mot de passe perdu ?", message: "Pas d'inquiétude !", preferredStyle: .Alert)
    print("hello")
    // Create the actions
    let okAction = UIAlertAction(title: "Envoie", style: UIAlertActionStyle.Default) {
      UIAlertAction in
      print("OK Pressed")
      print(alertController.textFields?.first!.text)
      print(alertController.textFields?.last?.text)
    }
    let cancelAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel) {
      UIAlertAction in
      NSLog("Cancel Pressed")
    }
    
    // Add the actions
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    
    alertController.addTextFieldWithConfigurationHandler { textField in
      //listen for changes
      textField.placeholder = "Username"
      //NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:", name: UITextFieldTextDidChangeNotification, object: textField)
    }
    alertController.addTextFieldWithConfigurationHandler { textField in
      //listen for changes
      textField.placeholder = "Email"
      //eNSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:", name: UITextFieldTextDidChangeNotification, object: textField)
    }
    // Present the controller
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  
  @IBAction func GoToRegisterPage(sender: AnyObject) {
    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RegisterPage") as? RegisterViewController
    vc?.saveFrameBtnLogin = self.btnLogin.frame
    print("avant segue: \(self.btnLogin.frame)")
    self.presentViewController(vc!, animated: false, completion: nil)
  }
  
  
  
  func secondAnimBtnLogin() {
    print("second anim")
    let goodFrame: CGRect = btnLogin.frame
    
    print("good: \(goodFrame)\nsave: \(saveFrameSignUp)")
    btnLogin.frame = saveFrameSignUp
    btnLogin.frame = CGRectMake(goodFrame.origin.x, saveFrameSignUp.origin.y, goodFrame.width, goodFrame.height)
    UIView.animateWithDuration(0.3, animations: {
      self.btnLogin.frame = goodFrame
      }, completion: nil)
  }
  
  func keyboardWillShow(notification: NSNotification) {
    print("bonjour")
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
      //let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
      let y = -keyboardSize.height + 16 + btnForgotPwd.frame.height
      
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
    if textField == self.loginTextfield {
      self.pwdTextfield.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
      
    }
    
    return false
  }
  
  
}

