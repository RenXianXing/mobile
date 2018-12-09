//
//  Api.swift
//  SCOOTER
//
//  Created by RoyIM on 11/16/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Stripe

struct Player {
    var userid:String
    var username: String
    var countryCode: String
    var phoneNumber: String
    var email:String
    var consumTime:Int
}

func startRiding(player:String, imei:String){
    let url = "https://ridebogo.com/admin/v1/api/startRiding"
    let startTime = getCurrentDateTime()
    let para = ["player": player, "imei": imei, "start_time":startTime]
    Alamofire.request(url, method: .post, parameters: para).validate().responseJSON { (response) in
    }
    
    
}

func endRiding(player:String, imei:String, time:Int, routhPath:[Any]){
    let url = "https://ridebogo.com/admin/v1/api/endRiding"
    let userid = UserDefaults.standard.value(forKey: "userid") as! String
    let imei = UserDefaults.standard.value(forKey: "imei") as! String
    let path = convertLocationToString(pathArr: routhPath)
    let endTime = getCurrentDateTime()
    if let pathStr = path {
        let para = ["player": userid, "imei": imei, "time":time, "path":pathStr, "end_time":endTime] as [String : Any]
        Alamofire.request(url, method: .post, parameters: para).validate().responseJSON { (response) in
        }
    }
    UserDefaults.standard.removeObject(forKey: "imei")
}

func getAvailablePaymentOptions(completion:@escaping (JSON)->()){
    let url = "https://ridebogo.com/admin/v1/api/getPaymentOptions"
    let para = ["get": "pot"]
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        switch response.result.isSuccess{
        case true:
            if let value = response.result.value {
                let json = parseJSON(value: value)
                completion(json)
            }
            return
            break
        case false:
            completion(JSON.null)
            return
            break
        }
        completion(JSON.null)
    }
    
}

func getPaymentHistyory(completion:@escaping (JSON)->()){
    let url = "https://ridebogo.com/admin/v1/api/getPaymentHistory"
    
    let userid = UserDefaults.standard.value(forKey: "userid") as! String
    let para = ["userid": userid]
    
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        switch response.result.isSuccess{
        case true:
            if let value = response.result.value {
                let json = parseJSON(value: value)
                completion(json)
            }
            return
            break
        case false:
            completion(JSON.null)
            return
            break
        }
        completion(JSON.null)
    }
    
}

func getTotalPrice(completion:@escaping (JSON)->()){
    let url = "https://ridebogo.com/admin/v1/api/getTotalPrice"
    let userid = UserDefaults.standard.value(forKey: "userid") as! String

    let para = ["userid": userid]
    
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        switch response.result.isSuccess{
        case true:
            if let value = response.result.value {
                let json = parseJSON(value: value)
                completion(json)
            }
            return
            break
        case false:
            completion(JSON.null)
            return
            break
        }
        completion(JSON.null)
    }
    
}

func getUserInfoDetail(completion:@escaping (JSON)->()){
    let url = "https://ridebogo.com/admin/v1/api/getUserDetail"
    let userid = UserDefaults.standard.value(forKey: "userid") as! String
    let para = ["userid": userid]
    
    print(para)
    
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        switch response.result.isSuccess{
        case true:
            if let value = response.result.value {
                let json = parseJSON(value: value)
                completion(json)
            }
            return
            break
        case false:
            completion(JSON.null)
            return
            break
        }
        completion(JSON.null)
    }
    
}


func submitTokenToBackend(_ token: STPToken, amount:String, completion: @escaping (_ response:
    String) -> Void) {
    
    
    let userid = UserDefaults.standard.value(forKey: "userid") as! String
    let username = UserDefaults.standard.value(forKey: "username") as! String
    
    let url = "https://ridebogo.com/admin/v1/api/createCharge"
    let para = ["id": userid,
                "email":"email@email.com",
                "username":username,
                "token":token.tokenId,
                "amount":amount]
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        switch response.result.isSuccess{
        case true:
            print(response.result)
            if let value = response.result.value {
                
                print(value)
                
                let json = parseJSON(value: value)
                if json["success"].boolValue {
                    completion("success")
                }else{
                    completion("fail")
                }
            }
            break
        case false:
            completion("response error")
            break
        }
    }
}

func getUserTripHistory(completion:@escaping (JSON)->()){
    let url = "https://ridebogo.com/admin/v1/api/getAllMyTrip"
    let userid = UserDefaults.standard.value(forKey: "userid") as! String
    let para = ["userid": userid]
    
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        switch response.result.isSuccess{
        case true:
            if let value = response.result.value {
                let json = parseJSON(value: value)
                completion(json)
            }
            return
            break
        case false:
            completion(JSON.null)
            return
            break
        }
        completion(JSON.null)
    }
}

func uploadDriverLicense(userImage : UIImage?,withCompletionHandler:@escaping (_ result: JSON) -> Void){
    let url = "https://ridebogo.com/admin/v1/api/upload_driver_license"
    Alamofire.upload(
        multipartFormData: { MultipartFormData in
            if((userImage) != nil){
                MultipartFormData.append(UIImageJPEGRepresentation(userImage!,  0.025)!, withName: "driver_license", fileName: "driver_license.jpeg", mimeType: "image/jpeg")
            }
    }, to: url) { (result) in
        
        switch result {
        case .success(let upload, _, _):
            upload.responseString { response in
                // getting success
                if let res = response.result.value {
                    withCompletionHandler(parseJSON(value: res))
                }
            }
        case .failure(let encodingError): break
            // getting error
        }
    }
}

func getToken(_ number: String, expMonth: String, expYear:String, cvc:String, withCompletionHandler:@escaping (_ tokenID: STPToken, _ error:String?) -> Void){
    let cardParams = STPCardParams()
    cardParams.number = number
    cardParams.expMonth = UInt(expMonth)!
    cardParams.expYear = UInt(expYear)!
    cardParams.cvc = cvc
    STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
        if let tokenVal = token{
            withCompletionHandler(tokenVal,error?.localizedDescription)
        }
    }
}

func add_card(_ card_number:String, expMonth:String, expYear:String, cvc:String, brand:String, withCompletionHandler:@escaping(_ result:Bool)->Void){

    let url = "https://ridebogo.com/admin/v1/api/addCreditCard"
    let userid = UserDefaults.standard.value(forKey: "userid") as! String
    let para = ["card_number": card_number,"exp_month": expMonth,"exp_year": expYear, "cvc":cvc,"brand":brand,"userid":userid]
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        
        var success = false
        
        switch response.result.isSuccess{
        case true:
            if let value = response.result.value {
                let json = parseJSON(value: value)
                success = json["success"].boolValue
            }
            break
        case false:
            break
        }
        withCompletionHandler(success)
    }
}

func getAllCreditCards(completion:@escaping (JSON)->()){
    let url = "https://ridebogo.com/admin/v1/api/getAllCreditCards"
    let userid = UserDefaults.standard.value(forKey: "userid") as! String
    let para = ["userid": userid]
    
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        switch response.result.isSuccess{
        case true:
            if let value = response.result.value {
                let json = parseJSON(value: value)
                completion(json)
            }
            return
            break
        case false:
            completion(JSON.null)
            return
            break
        }
        completion(JSON.null)
    }
    
}

func setDefaultCard(cardid:String,completion:@escaping (JSON)->()){
    let url = "https://ridebogo.com/admin/v1/api/updateDefaultCard"
    let userid = UserDefaults.standard.value(forKey: "userid") as! String
    let para = ["userid": userid, "cardid":cardid]
    
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        switch response.result.isSuccess{
        case true:
            if let value = response.result.value {
                let json = parseJSON(value: value)
                completion(json)
            }
            break
        case false:
            completion(JSON.null)
            break
        }
        completion(JSON.null)
    }
}

func removeCreditCard(cardid:String,completion:@escaping (JSON)->()){
    let url = "https://ridebogo.com/admin/v1/api/removeCreditCard"
    let userid = UserDefaults.standard.value(forKey: "userid") as! String
    let para = ["userid": userid, "cardid":cardid]
    
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        switch response.result.isSuccess{
        case true:
            if let value = response.result.value {
                let json = parseJSON(value: value)
                completion(json)
                return
            }
            break
        case false:
            completion(JSON.null)
            return
            break
        }
        completion(JSON.null)
    }
    
}

func getDefaultCardInfo(completion:@escaping (JSON)->()){
    let url = "https://ridebogo.com/admin/v1/api/getDefaultCardInfo"
    let userid = UserDefaults.standard.value(forKey: "userid") as! String
    let para = ["userid": userid]
    
    Alamofire.request(url, method: .post, parameters: para).validate().responseString { (response) in
        switch response.result.isSuccess{
        case true:
            if let value = response.result.value {
                let json = parseJSON(value: value)
                completion(json)
                return
            }
            break
        case false:
            completion(JSON.null)
            return
            break
        }
        completion(JSON.null)
    }
}

