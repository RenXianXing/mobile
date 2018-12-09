//
//  LaunchViewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/22/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import GoogleMaps


class LaunchViewController: UIViewController, CLLocationManagerDelegate{
    
    private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        //add observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(messageReceived(_ :)),
                                               name: .MessageReceived,
                                               object: nil)
        
        DispatchQueue.main.async(execute: {
            
            let userid = UserDefaults.standard.value(forKey: "userid") as? String
            let username = UserDefaults.standard.value(forKey: "username") as? String
            let imei = UserDefaults.standard.value(forKey: "imei") as? String
            
            if let useridVal = userid {
                if let imeiVal = imei {
                    let strInput = String(format: "%@,%@,%@,%@", "mobile", "check-in-use", imeiVal, useridVal, username!)
                    Connect.shared().sendMessage(message: strInput)
                    return
                }
                self.performSegue(withIdentifier: "segueToMainFromLaunch", sender: nil)
                return
            }
            self.performSegue(withIdentifier: "segueToLogin", sender: nil)
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func messageReceived(_ notification:Notification) {
        if let message = notification.userInfo!["message"] as? [String]{
            if(message[0] == "check-in-use" && message[1] == "0"){
                let rideVC = RideViewController()
                rideVC.imei = UserDefaults.standard.value(forKey: "imei") as! String
                self.navigationController?.pushViewController(rideVC, animated: true)
            }
            
            if(message[0] == "check-in-use" && message[1] == "1"){
                self.performSegue(withIdentifier: "segueToMainFromLaunch", sender: nil)
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
