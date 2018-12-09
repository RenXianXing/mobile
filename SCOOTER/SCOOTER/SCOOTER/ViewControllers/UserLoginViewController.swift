//
//  UserLoginViewController.swift
//  SCOOTER
//
//  Created by ll on 2018/9/19.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserLoginViewController: UIViewController{


    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickLogin(_ sender: UIButton) {
        let url = "https://ridebogo.com/admin/v1/api/client_login"
        let strName = textName.text
        let strPassword = textPassword.text
        textError.text = ""
        
        if let name = strName,
            let password = strPassword {
            let para = ["username": name, "password": password]
            Alamofire.request(url, method: .post, parameters: para).responseString { (response) in
                switch response.result.isSuccess{
                    case true:
                        if let value = response.result.value {
                            
                            let json = parseJSON(value: value)
                            let success = json["success"]
                            let userid = json["userid"].stringValue
                            let balance = json["balance"].stringValue
                            
                            if success.boolValue {
                                DispatchQueue.main.async {
                                    
                                    UserDefaults.standard.set(name, forKey: "username")
                                    UserDefaults.standard.set(userid, forKey: "userid")
                                    UserDefaults.standard.set(balance, forKey: "balance")
                                    
                                    
                                    self.performSegue(withIdentifier: "segueToMain", sender: nil)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.textError.text = json["msg"].stringValue
                               }
                            }
                        }
                        break
                    case false:
                        break
                }
                
            }
//            Alamofire.request(.POST, url, para, encoding: .JSON)
        }
    }
    
    @IBAction func onClickSignUpBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToSignUp", sender: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
