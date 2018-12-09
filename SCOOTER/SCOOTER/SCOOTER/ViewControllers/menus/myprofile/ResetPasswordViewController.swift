//
//  ResetPasswordViewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/18/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var old_pwd: UITextField!
    @IBOutlet weak var new_pwd: UITextField!
    @IBOutlet weak var confim_pwd: UITextField!
    @IBOutlet weak var textError: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onClickDone(_ sender: Any) {
        
        var para:[String:String] = [:]
        
        let userid = UserDefaults.standard.value(forKey: "userid") as! String
        para["userid"] = userid
        
        if let old_pwd_str = old_pwd.text {
            para["current_password"] = old_pwd_str
        }
        
        if let new_pwd_str = new_pwd.text {
            para["new_password"] = new_pwd_str
        }
        
        
        
        if(new_pwd.text != confim_pwd.text)
        {
            textError.text = "confirm password incorrect!"
            textError.textColor = UIColor.red
            return;
        }
        
        let url = "https://ridebogo.com/admin/v1/api/updatePassword"
        
        
        Alamofire.request(url, method: .post, parameters: para).responseString { (response) in
            switch response.result.isSuccess{
            case true:
                if let value = response.result.value {
                    
                    let json = parseJSON(value: value)
                    print(json)
                    let success = json["success"]
                    
                    
                    if success.boolValue {
                        DispatchQueue.main.async {
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
