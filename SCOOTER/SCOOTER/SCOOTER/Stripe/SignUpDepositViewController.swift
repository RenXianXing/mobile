//
//  DepositViewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/19/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Stripe

class SignUpDepositViewController: UIViewController ,STPAddCardViewControllerDelegate{
    
    @IBOutlet weak var lblChargeVal: UILabel!
    @IBOutlet weak var btnLowCharge: UIButton!
    @IBOutlet weak var btnMediumCharge: UIButton!
    @IBOutlet weak var btnHightCharge: UIButton!
    
    
    var deposit = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        changeButtonStyle(sender:btnLowCharge)
    }
    
    @IBAction func onClickLowCharge(_ sender: Any) {
        changeButtonStyle(sender:sender)
    }
    
    @IBAction func onClickMediumCharge(_ sender: Any) {
        changeButtonStyle(sender:sender)
        
    }
    @IBAction func onClickHightCharge(_ sender: Any) {
        changeButtonStyle(sender:sender)
        
    }
    @IBAction func onClickConfirm(_ sender: Any) {
        
        let message = String(format: "Confirm the %d$ deposit?",self.deposit)
        
        let alert = UIAlertController(title:"Alert", message: message, preferredStyle:UIAlertControllerStyle.alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) -> Void in
            self.handleAddPaymentMethodButtonTapped()
        }
        
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func changeButtonStyle(sender:Any){
        let activeButton = sender as! UIButton
        let price = (sender as! UIButton).tag
        self.deposit = price
        self.lblChargeVal.text = String(format:"$ %d",price)
        
        self.btnLowCharge.backgroundColor = UIColor(red:227.0/255.0, green: 227.0/255.0, blue: 227.0/255.0, alpha: 1.0)
        self.btnLowCharge.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        self.btnMediumCharge.backgroundColor = UIColor(red: 227.0/255.0, green: 227.0/255.0, blue: 227.0/255.0, alpha: 1.0)
        self.btnMediumCharge.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        self.btnHightCharge.backgroundColor = UIColor(red: 227.0/255.0, green: 227.0/255.0, blue: 227.0/255.0, alpha: 1.0)
        self.btnHightCharge.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        activeButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        activeButton.backgroundColor = UIColor(red: 0, green: 232.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        
    }
    
    
    //MARK: - Stripe Integration
    
    func handleAddPaymentMethodButtonTapped() {
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    // MARK: STPAddCardViewControllerDelegate
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // Dismiss add card view controller
        dismiss(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        submitTokenToBackend(token, amount: String(self.deposit), completion: { (response: String) in
            if response == "success"{
                addCardViewController.dismiss(animated: true, completion:{
                    self.performSegue(withIdentifier: "seguetoMain", sender: nil)
                })
            }else{
                let alert = UIAlertController(title: "Warnnig", message: "Billing is failed!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        })
        
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
