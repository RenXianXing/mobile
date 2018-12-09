//
//  MyTripsViewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/18/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit

class MyTripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblTrip: UITableView!
    var routesArr:[Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getUserTripHistory { (json) in
            print(json)
            self.routesArr = json.array
            self.tblTrip.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let routes = routesArr {
            return routes.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tripInfo = self.routesArr?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTripCell", for: indexPath) as! RideHistoryTableViewCell
        cell.setTripInfo(tripInfo)
        return cell
    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return CGFloat(128)
//    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
