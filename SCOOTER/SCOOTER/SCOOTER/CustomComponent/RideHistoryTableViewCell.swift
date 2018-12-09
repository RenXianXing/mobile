//
//  RideHistoryTableViewCell.swift
//  SCOOTER
//
//  Created by RoyIM on 11/21/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON

class RideHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblFromTo: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    var startMarker:ScooterMarker?
    var endMarker:ScooterMarker?
    
    private var locationManager = CLLocationManager()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func drawRoute(running:Bool){
//        let position = self.viewMap.camera.target
//        if startMarker == nil {
//            startMarker = ScooterMarker(latitude: position.latitude,longitude: position.longitude, mapView: self.viewMap, startMaker: true)
//        }
//
//        if lastPos != nil {
//            if let lastPosVal = lastPos {
//                let path = GMSMutablePath()
//                path.addLatitude(lastPosVal.latitude, longitude: lastPosVal.longitude)
//                path.addLatitude(position.latitude, longitude: position.longitude)
//                let route = GMSPolyline(path: path)
//                route.strokeColor = .blue
//                route.strokeWidth = 3.0
//                route.map = viewMap
//
//                self.routePath.append(lastPosVal)
//
//            }
//        }
//
//        if !running {
//            let endMarker = ScooterMarker(latitude: position.latitude,longitude: position.longitude, mapView: self.viewMap, startMaker: false)
//        }
//
//        lastPos = position
//
//    }
    
    public func setTripInfo(_ tripinfo:Any?){
        
        
//        mapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: 300, height: 258))
//        locationManager.requestWhenInUseAuthorization()
        
        if let info = tripinfo {
            let json = info as! JSON
            let unlock_time = json["unlock_time"].stringValue
            let lock_time = json["lock_time"].stringValue
            let total_time = json["total_time"].stringValue
            
            self.lblFromTo.text = String(format:"%@ - %@", unlock_time, lock_time)
            if let total_time_val = Int(total_time) {
                self.lblPrice.text = getPriceByTime(seconds: total_time_val)
            }
            let routeStr = json["route"].stringValue
            let routeJSON = parseJSON(value: routeStr)
            
            print(routeJSON)
            
            
            let routeArr = routeJSON["path"].array
            let startPos = routeArr?.first
            let endPos = routeArr?.last
            
            if let startPosVal = startPos {
                if startMarker == nil {
                    startMarker = ScooterMarker(latitude: startPosVal["latitude"].doubleValue, longitude: startPosVal["longitude"].doubleValue, mapView: mapView, startMaker: true)
                    let center = CLLocationCoordinate2D(latitude: startPosVal["latitude"].doubleValue, longitude: startPosVal["longitude"].doubleValue)
                    mapView.camera = GMSCameraPosition(target: center, zoom: 15, bearing: 0, viewingAngle: 0)
                }

            }
            
            
            if let endPosVal = endPos {
                if endMarker == nil {
                    endMarker = ScooterMarker(latitude: endPosVal["latitude"].doubleValue, longitude: endPosVal["longitude"].doubleValue, mapView: mapView, startMaker: false)
                }
                
            }
            
            drawRouter(routeArr)
            
            
        }
    }
    
    func drawRouter(_ routes:[JSON?]?){
        
        if startMarker != nil {
            
            if let routesArr = routes {
                let path = GMSMutablePath()
                if routesArr.count > 2 {
                    
                    for i in 0...(routesArr.count - 2) {
                        if let pos = routesArr[i] {
                            let latitude = pos["latitude"].doubleValue
                            let longitude = pos["longitude"].doubleValue
                            path.addLatitude(latitude, longitude: longitude)
                        }
                    }
                }
                let route = GMSPolyline(path: path)
                route.strokeColor = .blue
                route.strokeWidth = 3.0
                route.map = mapView
            }
            
        }
        
    }
}
