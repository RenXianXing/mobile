//
//  MyWalletViewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/18/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit

class MyWalletViewController: UIViewController {
    
    @IBOutlet weak var lblCurBalance: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfoDetail { (json) in
            
            let curBalance = json["balance"].stringValue
            self.lblCurBalance.text = String(format: "$ %@", curBalance)
            UserDefaults.standard.set(curBalance, forKey: "balance")
        }
        
    }
    

    @IBAction func onClickPayment(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToPayment", sender: nil)
    }
    @IBAction func onclickDeposit(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToDeposit", sender: nil)
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
