//
//  FindScooterViewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/21/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON

class FindScooterViewController: UIViewController, UITextFieldDelegate{
    
    
    var onTorch = true
    @IBOutlet weak var Lblcomment: UIView!
    @IBOutlet weak var textScooterID: UITextField!
    @IBOutlet weak var btnTorch: UIButton!
    var imei:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        textScooterID.delegate = self
        Lblcomment.layer.borderWidth = 2
        Lblcomment.layer.cornerRadius = 5.0
        Lblcomment.layer.borderColor = UIColor(red: 0, green: 232.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        
        btnTorch.roundCorners(corners: [.topLeft, .topRight], radius: 5.0)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //add observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(messageReceived(_ :)),
                                               name: .MessageReceived,
                                               object: nil)
    }
    
    @objc func messageReceived(_ notification:Notification) {
        
        if let message = notification.userInfo!["message"] as? [String]{
            if(message[0] == "unlock-scooter" && message[1] == "0"){
                NotificationCenter.default.removeObserver(self)
                let userid = UserDefaults.standard.value(forKey: "userid") as! String
                let imei = UserDefaults.standard.value(forKey: "imei") as! String
                startRiding(player: userid, imei: imei)
                let rideVC = RideViewController()
                rideVC.imei = imei
                self.navigationController?.pushViewController(rideVC, animated: true)
            }
            
            if(message[0] == "unlock-scooter" && message[1] == "3"){
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                showFailedAlertToUnlock()
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func onScooter(_ imei:String){
        let userid = UserDefaults.standard.value(forKey: "userid") as! String
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let strInput = String(format: "%@,%@,%@,%@,%@", "mobile", "unlock-scooter", imei, userid, username)
        Connect.shared().sendMessage(message: strInput)
    }
    
    
    @IBAction func toggleTorch(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: .video) else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if onTorch == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                onTorch = !onTorch
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Trouch is not availabe")
        }
        
    }
    
    @IBAction func scanByQrcode(_ sender:Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let serial_number = textScooterID.text!
        found(code:serial_number)
        return true
    }
    
    func found(code: String) {
        let url = "https://ridebogo.com/admin/v1/api/getScooterIMEIBySerial"
        let para = ["serial": code]
        Alamofire.request(url, method: .post, parameters: para).validate().responseJSON { (response) in
            switch response.result.isSuccess{
            case true:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.imei = json["imei"].string
                }
                break
            case false:
                break
            }
            if let imeiValue = self.imei {
                UserDefaults.standard.set(imeiValue, forKey: "imei")
                self.onScooter(imeiValue)
            }else{
                self.showWarnningAlert()
            }
        }
    }
    
    func showWarnningAlert(){
        let alert = UIAlertController(title:"Unlock failed", message: "Please, Enter the correct Scooter ID.", preferredStyle:UIAlertControllerStyle.alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showFailedAlertToUnlock(){
        let alert = UIAlertController(title:"Unlock failed", message: "This Scooter is in use now.", preferredStyle:UIAlertControllerStyle.alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) -> Void in
        }
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
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
