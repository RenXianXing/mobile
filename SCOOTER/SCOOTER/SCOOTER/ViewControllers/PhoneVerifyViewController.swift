//
//  PhoneVerifyViewController.swift
//  SCOOTER
//
//  Created by JinClevery on 9/15/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import PinCodeTextField

class PhoneVerifyViewController: UIViewController {
    
            
    @IBOutlet weak var labelPhonenumber: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var codeField: PinCodeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendSMS()
        codeField.keyboardType = UIKeyboardType.numberPad
    }
    
    @IBAction func sendSMS(_ sender: UIButton) {
        sendSMS()
    }
    
    @IBAction func clickNext(_ sender: UIButton) {
        if let verifycode = codeField.text {

            let phoneNumber = UserDefaults.standard.value(forKey: "phone_number") as! String
            let country_code = UserDefaults.standard.value(forKey: "country_code") as! String
            
            VerifyAPI.validateVerificationCode(country_code, phoneNumber, verifycode) { checked in
                if (checked.success) {
                    self.errorLabel.text = checked.message
                    if(checked.success){
                        self.performSegue(withIdentifier: "segueToSignInfo", sender: nil)
                    }
                } else {
                    self.errorLabel.text = checked.message
                }
            }
        }
        
//        self.performSegue(withIdentifier: "segueToSignInfo", sender: nil)
        
        
    }
    
    func sendSMS(){
        let phoneNumber = UserDefaults.standard.value(forKey: "phone_number") as! String
        let country_code = UserDefaults.standard.value(forKey: "country_code") as! String
        labelPhonenumber.text = phoneNumber
        VerifyAPI.sendVerificationCode(country_code, phoneNumber)
    }
}
