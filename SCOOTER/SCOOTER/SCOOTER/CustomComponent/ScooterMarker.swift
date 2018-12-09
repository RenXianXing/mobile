//
//  ScooterMarker.swift
//  SCOOTER
//
//  Created by RoyIM on 11/12/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ScooterMarker: GMSMarker {
    
    init(latitude:String, latitude_hemisphere:String, longitude: String,longitude_hemisphere:String, mapView:GMSMapView){
        super.init()
        let latitudeStr = convertLatitudeValue(latitude: latitude, latitude_hemisphere: latitude_hemisphere)
        let longitudeStr = convertLongitudeValue(longitude: longitude, longitude_hemisphere:longitude_hemisphere)
        self.position = CLLocationCoordinate2D(latitude:Double(latitudeStr)!, longitude:Double(longitudeStr)!)
        self.map = mapView
        self.icon = UIImage(named:"scooter_marker")
    }
    
    init(latitude:CLLocationDegrees,longitude:CLLocationDegrees, mapView:GMSMapView, startMaker:Bool){
        super.init()
        self.position = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
        self.map = mapView
        if startMaker {
            self.icon = UIImage(named:"start_marker")
        }else{
            self.icon = UIImage(named:"end_marker")
        }
    }
}
