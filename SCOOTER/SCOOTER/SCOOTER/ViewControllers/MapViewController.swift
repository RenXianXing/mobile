//
//  mapViewController.swift
//  SCOOTER
//
//  Created by JinClevery on 9/13/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SideMenu
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController {
    @IBOutlet weak var buttonQRscan: UIButton!
    @IBOutlet weak var viewMap: GMSMapView!
    
    
    private var locationManager = CLLocationManager()
    var scooters:[ScooterMarker] = []
    var status = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // init UI
        buttonQRscan.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        //add observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(messageReceived(_ :)),
                                               name: .MessageReceived,
                                               object: nil)
        
        
        if let userid = UserDefaults.standard.value(forKey: "userid"){
            
            sendCommnadToGetAllScooters()
            
            getUserInfoDetail { (json) in
                let curBalance = json["balance"].stringValue
                UserDefaults.standard.set(curBalance, forKey: "balance")
                showRequireChargingBalanceNotification(balance: curBalance, completion: nil)
            }
        }else{
            
            let lauchVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC")
            self.present(lauchVC!, animated: false, completion: nil)
            
        }
        
        checkLocationServiceEnabled()
    }
    
    
    func checkLocationServiceEnabled(){
        DispatchQueue.main.asyncAfter(deadline: .now() +  1) {
            
            var enabled = false
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    break
                case .authorizedAlways, .authorizedWhenInUse:
                    enabled = true
                    break
                }
            }
            
            if !enabled {
                let alert = UIAlertController(title:"Enable Location", message: "Please enable location services to see nearby bogo scooters.", preferredStyle:UIAlertControllerStyle.alert)
                
                
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
                
                alert.addAction(settingsAction)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
                    self.checkLocationServiceEnabled()
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickMenu(_ sender: UIBarButtonItem) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        // Similarly, to dismiss a menu programmatically, you would do this:
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickQRcode(_ sender: Any) {
        let balance = UserDefaults.standard.value(forKey: "balance") as! String
        showRequireChargingBalanceNotification(balance: balance) {(success) in
            if success {
                self.performSegue(withIdentifier: "segueToQRcode", sender:nil)
            } else {
                
            }
        }
    }
    
    func initGoogleMap() {
        viewMap.settings.myLocationButton = true
        viewMap.isMyLocationEnabled = true
    }
    
    
    @objc func messageReceived(_ notification:Notification) {
        
        if let message = notification.userInfo!["message"] as? [String]{
            
            //... Handle Message
            if message[0] == "get-all-scooters" {
                
                
                removeAllMarkers()
                
                var json = message[1]
                
                if(message.count > 2){
                    
                    for i in 2...(message.count - 1){
                        
                        json += "," + message[i]
                        
                    }
                    
                }
                
                if let data = json.data(using: .utf8) {
                    if let json = try? JSON(data: data) {
                        print(json)
                        for item in json["scooters"].arrayValue {
                            
                            if(item != JSON.null){
                                print(item["latitude"].stringValue)
                                print(item["longitude"].stringValue)
                                let scooterMarker = ScooterMarker(latitude:item["latitude"].stringValue,
                                                                  latitude_hemisphere:item["latitude_hemisphere"].stringValue,
                                                                  longitude:item["longitude"].stringValue,
                                                                  longitude_hemisphere:item["longitude_hemisphere"].stringValue,
                                                                  mapView:viewMap)
                                scooters.append(scooterMarker)
                                
                            }
                            
                        }
                    }
                }
                
            }
            
            
            if(message[0] == "unlock-scooter" && message[1] == "0"){
                
                NotificationCenter.default.removeObserver(self)
                let userid = UserDefaults.standard.value(forKey: "userid") as! String
                let imei = UserDefaults.standard.value(forKey: "imei") as! String
                startRiding(player: userid, imei: imei)
                let rideVC = RideViewController()
                rideVC.imei = imei
                self.navigationController?.pushViewController(rideVC, animated: true)
                
            }
            
        }
    }
    
    func removeAllMarkers(){
        for item in scooters {
            item.map = nil
        }
        scooters = []
    }
    
    
    
    func sendCommnadToGetAllScooters(){
        let userid = UserDefaults.standard.value(forKey: "userid") as! String
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let strInput = String(format:"mobile,get-all-scooters,0,%@,%@",userid,username)
        Connect.shared().sendMessage(message: strInput)
    }
}
// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        CLLocationManager.authorizationStatus()
        // 3
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            initGoogleMap();
        }
        // 4
        
    }
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let location = locations.first else {
            return
        }
        // 7
        viewMap.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // 8
        locationManager.stopUpdatingLocation()
        
    }
}

