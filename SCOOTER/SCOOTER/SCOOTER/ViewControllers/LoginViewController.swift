//
//  ViewController.swift
//  SCOOTER
//
//  Created by JinClevery on 9/13/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SideMenu
import NKVPhonePicker
import Alamofire


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate{
    @IBOutlet weak var phonePicker: NKVPhonePickerTextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phonePicker.phonePickerDelegate = self
        
        
        fbLoginButton.readPermissions = ["public_profile", "email"]
        
        fbLoginButton.delegate = self
        
        if FBSDKAccessToken.current() != nil {
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let fbDetails = result as! NSDictionary
                    print(fbDetails)
                    let username = fbDetails.object(forKey: "name") as! String
                    let email = fbDetails.object(forKey: "email") as! String
                    let id = fbDetails.object(forKey: "id") as! String

                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(id, forKey: "userid")
                    UserDefaults.standard.set(email, forKey: "email")
                }
            })
            print("logged in")
        }else{
            print("not logged")
        }
        
        // Extend the code sample from 6a. Add Facebook Login to Your Code
        // Add to your viewDidLoad method:
        
        
        
    }

    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        print(result)
        
        if error != nil {
            
        }else if result.isCancelled {
            
            print("user canceled loged in")
            
        }else{
            //successfull login
            print("user loged in via facebook")
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("loged out")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickNextButton(_ sender: UIButton) {
        
        if let code = phonePicker.code {
            UserDefaults.standard.set(code, forKey: "country_code")
        }

        if let phoneNum = phonePicker.phoneNumber {
            UserDefaults.standard.set(phoneNum, forKey: "phone_number")
        }

        self.performSegue(withIdentifier: "segueVerify", sender: nil)
    }
    
    
    
}

