//
//  helper.swift
//  SCOOTER
//
//  Created by RoyIM on 11/11/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//https://i.diawi.com/d6Nqve

import Foundation
import SwiftyJSON
import GoogleMaps
import GooglePlaces


func secondsToMinSeconds(seconds: Int) -> (String) {
    let mins = seconds / 60
    let secs = seconds % 60
    var minStr = ""
    var secStr = ""
    if mins < 10 {
        minStr = String(format:"0%d", mins)
    } else {
        minStr = String(format:"%d", mins)
    }
    
    if secs < 10 {
        secStr = String(format:"0%d", secs)
    }else{
        secStr = String(format:"%d", secs)
    }
    
    return String(format:"%@:%@", minStr, secStr)
    
}

//eg. 07717.3644 E is the DDDMM.MMMM format
//
//077 --> degrees
//17 --> minutes
//    .3644 --> minutes equals to sec/60
//
//
//decimal = degrees + minutes/60
//
//decimal = 77 + (17.3644 / 60)
//
//decimal = 77.28941



func convertLatitudeValue(latitude :String,latitude_hemisphere:String ) -> String{
    var indexStartOfText = latitude.index(latitude.startIndex, offsetBy: 0)
    var indexEndOfText = latitude.index(latitude.startIndex, offsetBy: 2)
    var result = (latitude[indexStartOfText..<indexEndOfText] as NSString).floatValue
    
    
    indexStartOfText = latitude.index(latitude.startIndex, offsetBy:2)
    indexEndOfText = latitude.index(latitude.startIndex, offsetBy:9)
    
    result += (latitude[indexStartOfText..<indexEndOfText] as NSString).floatValue / 60
    
    if latitude_hemisphere == "S" {
        return String(format:"-%@f",result);
    }
    return String(format:"%f",result)
}

func convertLongitudeValue(longitude :String, longitude_hemisphere:String) -> String{
    var indexStartOfText = longitude.index(longitude.startIndex, offsetBy: 0)
    var indexEndOfText = longitude.index(longitude.startIndex, offsetBy: 3)
    var result = (longitude[indexStartOfText..<indexEndOfText] as NSString).floatValue
    
    
    indexStartOfText = longitude.index(longitude.startIndex, offsetBy:3)
    indexEndOfText = longitude.index(longitude.startIndex, offsetBy:10)
    
    result += (longitude[indexStartOfText..<indexEndOfText] as NSString).floatValue / 60
    
    if longitude_hemisphere == "W" {
        return String(format:"-%f",result);
    }
    return String(format:"%f",result)
}


func parseJSON(value:String)->JSON{
    if let data = value.data(using: .utf8) {
        if let json = try? JSON(data: data) {
            return json
        }
    }
    return JSON.null
}

func getPriceByTime(seconds:Int)->String{
    let totalPrice = 1.15 + 0.15 * ceilf(Float(seconds / 60))
    
    return String(format: "$%.2f", totalPrice)
    
}

func getteleNumberFromPhoneNumber(code:String, phoneNum:String)->String{
    
    let indexStartOfText = phoneNum.index(phoneNum.startIndex, offsetBy: (code.count))
    let indexEndOfText = phoneNum.index(phoneNum.startIndex, offsetBy: (phoneNum.count))
    let result = String(phoneNum[indexStartOfText..<indexEndOfText]) as String

    return result
    
}

func convertLocationToString(pathArr:[Any])->String? {
    
    let arr = pathArr as! [CLLocationCoordinate2D]
    var jsonArr = [[String:Any]]()
    
    for i in 0...(arr.count - 1) {
        let pos = arr[i] as CLLocationCoordinate2D
        let dic = ["latitude":pos.latitude, "longitude":pos.longitude]
        jsonArr.append(dic)
    }
    
    let jsonObj = ["path":jsonArr]
    
    let validateJson = JSONSerialization.isValidJSONObject(jsonObj)
    
    if validateJson {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObj, options: []) else {
            return nil
        }
        
        let result = String(data: data, encoding: String.Encoding.utf8)
        return result
    } else {
        return nil
    }
    
}

func getCurrentDateTime()->String{
    
    let date = Date()
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date)
    
}
