//
//  CardCell.swift
//  SCOOTER
//
//  Created by RoyIM on 11/28/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import SwiftyJSON

class CardCell: UICollectionViewCell {
    
    var id:String?
    var number:String?
    var brand:String?
    var status = "unactive"
    var exp_month = ""
    var exp_year = ""
    
    @IBOutlet weak var lblCardNumber4: UILabel!
    @IBOutlet weak var lblDefault: UILabel!
    @IBOutlet weak var lblBrand: UILabel!
    
    func setCardInfo(_ cardinfo:Any?){
        
        if let info = cardinfo {
            let json = info as! JSON
            let status = json["status"].stringValue
            let exp_year = json["exp_year"].stringValue
            let exp_month = json["exp_month"].stringValue
            let cardnumber = json["card_number"].stringValue
            let cvc = json["cvc"].stringValue
            let brand = json["brand"].stringValue
            
            lblCardNumber4.text = CreditCardValidator.getFormattedLastDigist(brand: brand, cardnumber: cardnumber)
            lblBrand.text = brand
            if status == "active" {
                lblDefault.text = "Default"
            }else{
                lblDefault.text = ""
            }
            self.number = cardnumber
            self.brand = brand
            self.exp_month = exp_month
            self.exp_year = exp_year
            self.status = status
        }
        
    }
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 15.0
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor(red: 0, green: 232.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
    }
    
}
