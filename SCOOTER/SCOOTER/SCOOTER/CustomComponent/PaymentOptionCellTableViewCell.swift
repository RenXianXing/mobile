//
//  PaymentOptionCellTableViewCell.swift
//  SCOOTER
//
//  Created by RoyIM on 11/14/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit

class PaymentOptionCellTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var lblCost: UILabel!
    
    var cost = "0"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCost(cost:String){
        
        self.lblCost.text = String(format: "%@$", cost)
        self.cost = cost
        
    }

}
