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

class DepositViewController: UIViewController{

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
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        getDefaultCardInfo { (json) in
            if json == JSON.null {
                UIViewController.removeSpinner(spinner: sv)
                self.performSegue(withIdentifier: "segueToaddCardFromDeposit", sender: nil)
            }else{
                let cardnumber = json["card_number"].stringValue
                let exp_month = json["exp_month"].stringValue
                let exp_year = json["exp_year"].stringValue
                let cvc = json["cvc"].stringValue

                getToken(cardnumber, expMonth: exp_month, expYear: exp_year, cvc: cvc, withCompletionHandler: { (token, error) in
                    
                    submitTokenToBackend(token, amount: String(self.deposit), completion: { (response: String) in
                        
                        UIViewController.removeSpinner(spinner: sv)
                        
                        if response == "success"{
                            if let oldBalance = Float(UserDefaults.standard.value(forKey: "balance") as! String) {
                                let curBalance = oldBalance + Float(self.deposit)
                                let title = String(format:"PAYMENT $%d SUCCESSFUL", self.deposit)
                                let message = String(format:"YOUR BALANCE IS $%.2f",curBalance)
                                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ (alert: UIAlertAction!) in
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }else{
                            let alert = UIAlertController(title: "Warnnig", message: "Billing is failed!", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                })
                
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
