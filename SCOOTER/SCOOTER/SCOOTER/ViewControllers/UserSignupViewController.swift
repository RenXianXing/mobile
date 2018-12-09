//
//  UserSignupViewController.swift
//  SCOOTER
//
//  Created by ll on 2018/9/19.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserSignupViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var textFirstName: UITextField!
    @IBOutlet weak var textLastdName: UITextField!
    @IBOutlet weak var textDisplayName: UITextField!
    @IBOutlet weak var textAddress: UITextField!
    @IBOutlet weak var textEmail: UITextField!
    
    @IBOutlet weak var textBirthday: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textConfirmPassword: UITextField!
    @IBOutlet weak var imageViewLicense: UIImageView!
    
    private var birthdayPicker:UIDatePicker?
    
    var  licenseImageName:String?
    
    var imagePickerVC = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        birthdayPicker = UIDatePicker()
        birthdayPicker?.datePickerMode = .date
        birthdayPicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        textBirthday.inputView = birthdayPicker

        imagePickerVC.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        
        imageViewLicense.isUserInteractionEnabled = true
        imageViewLicense.addGestureRecognizer(tapGestureRecognizer)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {			
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func imageTapped(tapGestureRecognizer:UITapGestureRecognizer){
        self.present(imagePickerVC, animated: true, completion: nil)
    }
    
    @objc func dateChanged(datePicker:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        self.textBirthday.text = dateFormatter.string(from: datePicker.date)
//        view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let tempImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        imageViewLicense.image = tempImage
        self.imagePickerVC.dismiss(animated: true, completion: nil)
        
        uploadDriverLicense(userImage: tempImage) { (result) in
//            self.imagePickerVC.dismiss(animated: true, completion: nil)
            if result["error"] != JSON.null {
                print(result["error"])
                return
            }
            print(result)
            self.licenseImageName = result["upload_data"]["raw_name"].string
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerVC.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSignup(_ sender: UIButton) {
        
//        self.performSegue(withIdentifier: "segueToPaymentSetting", sender: nil)
//        Connect.shared().PLAYER.userid = "10"
//        return
        
        let url = "https://ridebogo.com/admin/v1/api/client_signup"
//        textError.text = ""
//
        let strfirstName = textFirstName.text
        let strlastName = textLastdName.text
        let strUserName = textDisplayName.text
        let strPassword = textPassword.text
        let strAddress = textAddress.text
        let strBirtday = textBirthday.text
        let strEmail = textEmail.text
        var countryCode = UserDefaults.standard.value(forKey: "country_code") as! String
        var phoneNumber = UserDefaults.standard.value(forKey: "phone_number") as! String
        
        countryCode = "86"
        phoneNumber = "123456789"
        
        if !validateInputVal() {
            return
        }
        
        let para = ["first_name": strfirstName!,
                    "last_name": strlastName!,
                    "username": strUserName!,
                    "email": strEmail!,
                    "password": strPassword!,
                    "address": strAddress!,
                    "country_code": countryCode,
                    "phone_number":phoneNumber,
                    "driver_license":self.licenseImageName!,
                    "birthday": strBirtday!]
        Alamofire.request(url, method: .post, parameters: para).responseString { (response) in
            switch response.result.isSuccess{
                case true:
                    if let value = response.result.value {
                        
                        let json = parseJSON(value: value)
                        let success = json["success"]
                        let userid = json["userid"].stringValue
                        
                        if success.boolValue {
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(String(format: "%@ %@", strfirstName!, strlastName!), forKey: "username")
                                UserDefaults.standard.set(userid, forKey: "userid")
                                self.performSegue(withIdentifier: "segueToPaymentSetting", sender: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlertWarnningMessage("Warnning", message: json["msg"].stringValue)
                            }
                        }
                    }
                    break
                case false:
                    break
            }
        }
//      Alamofire.request(.POST, url, para, encoding: .JSON)
        
    }
    @IBAction func clickCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func showAlertWarnningMessage(_ title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func validateInputVal()->Bool{
        
        let strfirstName = textFirstName.text
        let strlastName = textLastdName.text
        let strPassword = textPassword.text
        let strConfirmPassword = textConfirmPassword.text
        let strAddress = textAddress.text
        let strLicense = self.licenseImageName
        let strBirtday = textBirthday.text
        let strEmail = textEmail.text
        
        if(strPassword != strConfirmPassword)
        {
            self.showAlertWarnningMessage("Password warrning", message: "Please, confirm password.")
            return false;
        }
        if(strfirstName == "" || strlastName == "" || strEmail == "" || strPassword == "" || strAddress == "" || strLicense == nil || strBirtday == ""){
            self.showAlertWarnningMessage("Input warrning", message: "Please, provide all information.")
            return false;
        }
        
        return true
        
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
