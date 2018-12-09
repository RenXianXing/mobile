//
//  MyProfileViewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/18/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class MyProfileViewController: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtCountryCode: UITextField!
    @IBOutlet weak var txtTelNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserInfoDetail { (json) in
            print(json)
            if json != JSON.null {
                DispatchQueue.main.async {
                    self.txtName.text = json["name"].stringValue
                    self.txtEmail.text = json["email"].stringValue
                    self.txtCountryCode.text = json["country_code"].stringValue
                    self.txtTelNumber.text = getteleNumberFromPhoneNumber(code: json["country_code"].stringValue, phoneNum: json["phone_number"].stringValue)
                    
                }
            }
        }
    }
    
    @IBAction func onClickPasswordReset(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToPasswordReset", sender: nil)
    }
    
    @IBAction func onClickDone(_ sender: Any) {
        var para:[String:String] = [:]
        let userid = UserDefaults.standard.value(forKey: "userid") as! String
        para["userid"] = userid
        if let name = txtName.text {
            para["username"] = name
        }
        if let email = txtEmail.text {
            para["email"] = email
        }
        
        if let country_code = txtCountryCode.text {
            para["country_code"] = country_code
            if let phone_number = txtTelNumber.text {
                para["phone_number"] = String(format: "%@%@", country_code, phone_number)
            }
        }

       let url = "https://ridebogo.com/admin/v1/api/saveUserDetail"


        Alamofire.request(url, method: .post, parameters: para).responseString { (response) in
            switch response.result.isSuccess{
            case true:
                if let value = response.result.value {

                    print(value)

                    let json = parseJSON(value: value)
                    print(json)
                    let success = json["success"]


                    if success.boolValue {
                        DispatchQueue.main.async {
                            if let name = self.txtName.text {
                                UserDefaults.standard.set(name, forKey: "username")
                            }
                            
                            let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "NavigationViewController")
                            self.present(mapVC!, animated: true, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async {

                        }
                    }
                }
                break
            case false:
                break
            }
        }
        
        
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
