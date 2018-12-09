//
//  AddCreditorDebitCardviewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/28/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit

class AddCreditorDebitCardviewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtMMYY: UITextField!
    @IBOutlet weak var txtCVC: UITextField!
    var cardValidator = CreditCardValidator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickSave(_ sender: Any){
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        let strNumber = txtCardNumber.text!.replacingOccurrences(of: " ", with: "")
        if let type = cardValidator.type(from: strNumber) {
            let arrMMYY = txtMMYY.text!.components(separatedBy: "/")
            if arrMMYY.count == 2 {
                let strMM = arrMMYY[0]
                let strYY = arrMMYY[1]
                let strCVC = txtCVC.text!
                getToken(strNumber, expMonth: strMM, expYear: strYY, cvc: strCVC) { (token, error) in
                    if let errorMsg = error {
                        print(errorMsg)
                    }
                    add_card(strNumber, expMonth: strMM, expYear: strYY, cvc: strCVC, brand: type.name, withCompletionHandler: { (flag) in
                        if flag {
                            UIViewController.removeSpinner(spinner: sv)
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            }
        } else {
            print("no available card number")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if range.length > 0 {
//            return true
//        }
        
        let tag = textField.tag
        var originalText = textField.text
        let replacementText = string.replacingOccurrences(of: " ", with: "")
        
        //veryfy entered text is a numeric value
        if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: replacementText)) {
            return false
        }
        
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char,"\\b")
        
        if isBackSpace != -92 {
            switch tag {
                case 1:
                    if range.location % 5 == 0 {
                        originalText?.append(" ")
                        textField.text = originalText
                    }
                    break
                case 2:
                    if range.location > 4 {
                        return false
                    }
                    if range.location == 2{
                        originalText?.append("/")
                        textField.text = originalText
                    }
                    break
                case 3:
                    if range.location > 3 {
                        return false
                    }
                    break
                default:
                    break
            }
        }
    
        if string == " " {
            return false
        }
        return true
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
