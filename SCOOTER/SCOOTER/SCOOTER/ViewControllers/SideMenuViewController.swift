//
//  SideMenuViewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/21/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import Foundation
import SideMenu

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var lblUserName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let username = UserDefaults.standard.value(forKey: "username") as! String
        
        lblUserName.text = String(format:"Hi, %@",username)
        guard SideMenuManager.default.menuBlurEffectStyle == nil else {
            return
        }
    }

    @IBAction func onClickLogOutBtn(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "userid")
        
        dismiss(animated: true, completion: nil)
        
        
//        let lauchVC = self.storyboard?.instantiateViewController(withIdentifier: "lauchVC")
//        self.present(lauchVC!, animated: false, completion: nil)
        
        
    }
    
    
    @IBAction func onClickTermsBtn(_ sender: Any) {
        guard let url = URL(string:"https://ridebogo.com") else { return }
        UIApplication.shared.open(url)
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
