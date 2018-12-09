//
//  RideViewController.swift
//  SCOOTER
//
//  Created by ll on 2018/11/9.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON


class RideViewController: UIViewController{
    
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var lblTrackedTime: UILabel!
    @IBOutlet weak var lblPower: UILabel!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblMode: UILabel!

    public var imei:String!
    private var timer:Timer!
    private var trackedTime:Int!
    
    private var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    // The currently selected place.
    var selectedPlace: GMSPlace?
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    var startMarker:ScooterMarker?
    var lastPos:CLLocationCoordinate2D?
    var trackedPath = GMSMutablePath()
    var trackedPolyline = GMSPolyline()
    
    var routePath  = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        //init timer
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.sendTCPRequest), userInfo: nil, repeats: true)
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //add observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(messageReceived(_ :)),
                                               name: .MessageReceived,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func messageReceived(_ notification:Notification) {
        if let message = notification.userInfo!["message"] as? [String]{
            //... Handle Message
            
            if(message[0] == "get-scooter-power-speed-mode-time") {
                //            ${power},${speed},${mode}`
                if(message[1] == "get-scooter-power-speed-mode-time"){
                    print(message)
                }
                self.trackedTime = Int(message[4])
                self.updateScooterInfo(time:self.trackedTime, power: message[1], speed: message[2], mode: message[3])
            }
            
            if(message[0] == "lock-scooter" && message[1] == "0"){
                
                self.timer.invalidate()
                let userid = UserDefaults.standard.value(forKey: "userid") as! String
                let imei = UserDefaults.standard.value(forKey: "imei") as! String
                
                let latitude = message[2]
                let latitude_hemisphere = message[3]
                let longitude = message[4]
                let longitude_hemisphere = message[5]
                
                let scooter_Pos = CLLocationCoordinate2D(latitude: Double(convertLatitudeValue(latitude: latitude, latitude_hemisphere: latitude_hemisphere))!,
                                                 longitude: Double(convertLongitudeValue(longitude: longitude, longitude_hemisphere: longitude_hemisphere))!)
                self.routePath.append(scooter_Pos)
                endRiding(player: userid, imei: imei, time: self.trackedTime, routhPath:self.routePath)
                
                
                let priceResultVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PriceResultViewController") as? PriceResultViewController
                priceResultVC?.totalTime = self.trackedTime
                self.present(priceResultVC!, animated: true, completion: nil)
            }
            
        }
    }

    //MARK: - IBACTION func
    @IBAction func lockAndBill(_ sender: Any) {
        showConfirmAlert()
    }
    
    func showConfirmAlert(){
        let alert = UIAlertController(title:"Alert", message: "Are you sure to end ride?", preferredStyle:UIAlertControllerStyle.alert)
        let lockAction = UIAlertAction(title: "Confirm", style: .default) { (_) -> Void in
            //lock
            let userid = UserDefaults.standard.value(forKey: "userid") as! String
            let imei = UserDefaults.standard.value(forKey: "imei") as! String
            let username = UserDefaults.standard.value(forKey: "username") as! String
            let strInput = String(format:"mobile,lock-scooter,%@,%@,%@", imei, userid, username)
            Connect.shared().sendMessage(message: strInput)
        }
        
        alert.addAction(lockAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Google Map API
    
    func initGoogleMap() {
        viewMap.settings.myLocationButton = true
        viewMap.isMyLocationEnabled = true
    }
    
    //MARK: - TCP communication func
    
    @objc func sendTCPRequest() {
        //ping to scooter to get status info
        let imei = UserDefaults.standard.value(forKey: "imei") as! String
        let userid = UserDefaults.standard.value(forKey: "userid") as! String
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let strInput = String(format: "mobile,get-scooter-power-speed-mode-time,%@,%@,%@",imei, userid, username)
        print(strInput)
        DispatchQueue.main.async {	
            Connect.shared().sendMessage(message: strInput)
        }
    }
    
    func drawRoute(running:Bool, lastPos:CLLocationCoordinate2D){
        viewMap.clear()
        if startMarker == nil {
            startMarker = ScooterMarker(latitude: lastPos.latitude,longitude: lastPos.longitude, mapView: self.viewMap, startMaker: true)
        }
        startMarker?.map = self.viewMap
        trackedPath.addLatitude(lastPos.latitude, longitude: lastPos.longitude)
        trackedPolyline.path = trackedPath
        trackedPolyline.strokeColor = .blue
        trackedPolyline.strokeWidth = 3.0
        trackedPolyline.map = viewMap
        self.routePath.append(lastPos)
    }
    
    func initEndMarker(){
        let position = self.viewMap.camera.target
        let endMarker = ScooterMarker(latitude: position.latitude,longitude: position.longitude, mapView: self.viewMap, startMaker: false)
    }
    
    //MARK: - Update UI
    func updateScooterInfo(time:Int?, power:String, speed:String, mode:String ){
        if let timeVal = time {
            self.lblTrackedTime.text = secondsToMinSeconds(seconds:timeVal)
        }
        print("updating scooter info ....")
        self.lblPower.text = String(format: "%@%@", power, " %")
//        self.lblSpeed.text = String(format: "%@%@", speed, " mile/h")
        self.lblMode.text = String(format: "%@", mode)
    }
    
    func DrawPathBeteenPostion(){
        
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

// MARK: - CLLocationManagerDelegate
extension RideViewController: CLLocationManagerDelegate {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            initGoogleMap();
        }
    }
    
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let location = locations.first else {
            return
        }
        viewMap.camera = GMSCameraPosition(target: location.coordinate, zoom: 15 , bearing: 0, viewingAngle: 0)
        
        if let last_position = locations.last {
            drawRoute(running:true, lastPos: last_position.coordinate)
        }

//        locationManager.stopUpdatingLocation()
    }
    
    
//    func initScooterMarker(latitude:CLLocationDegrees, longitude: CLLocationDegrees){
//        scooterMarker = GMSMarker()
////        scooterMarker.position = viewMap.camera.target
//        scooterMarker.position = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
//
////        scooterMarker.title = "Palo Alto"
////        scooterMarker.snippet = "San Francisco"
//        scooterMarker.map = viewMap
//    }
    
    
}
