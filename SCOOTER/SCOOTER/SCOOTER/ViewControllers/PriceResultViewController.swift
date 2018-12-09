//
//  PriceResultViewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/13/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import SwiftyJSON
import UserNotifications

class PriceResultViewController: UIViewController{
    
    

    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var lblTotalFare: UILabel!
    @IBOutlet weak var navToMapView: UIBarButtonItem!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblFare: UILabel!
    
    var totalTime:Int!
    var historyArr = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        let priceStr = getPriceByTime(seconds: totalTime)
        
        showEndRidingNotification(cost: priceStr, completion: nil)
        lblTotalTime.text = secondsToMinSeconds(seconds: totalTime)
        lblTotalFare.text = String(format: "%@", priceStr)
        
        self.lblName.text = UserDefaults.standard.value(forKey: "username") as? String
        self.lblFare.text = String(format: "%@", priceStr)
        self.lblTime.text = secondsToMinSeconds(seconds: totalTime)
        
        
        
    }
    
    @IBAction func onClickToMapBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToMapview", sender: nil)
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
