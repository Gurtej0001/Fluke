//
//  NearByModel.swift
//  Fluke
//
//  Created by JP on 03/05/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class NearByModel: NSObject {
    
    var strId = ""
    var strUserFirstName = ""
    var strUserLastName = ""
    var strUserDisplayName = ""
    var strEmailId = ""
    var strGender = ""
    var strUserAge = ""
    var strAboutMe = ""
    var strUserCountry = ""
    var strUserCity = ""
    var distance = ""
    var strDeviceType = ""
    var isVerify = false
    var strIsCommunityUser = ""
    var strDeviceToken = ""
    var strAccessToken = ""
    var strLat = ""
    var strLong = ""
    var strPostCode = "345543"
    var isDND = false
    var strProfileImage = ""
    
    var strCurrentPage = ""
    var strTotalPage = ""
    
    func getListOfNewarBy(strPage: String, strLat: String, strLong:String, strGender: String, success:@escaping ([NearByModel]) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APINearestUser)
        let dictParam = ["gender":strGender,
                         "page_no":strPage,
                         "longitude":strLong,
                         "latitude":strLat]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            success(self.createListOfAllUsers(response: response!))
            
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    func getRandomUser(gender:String, country: String, success:@escaping (NearByModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIGetRandomUser)
        let dictParam = ["gender":gender,
                         "country":country]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            let json = JSON(response as Any)
            let dictResponse = json.dictionary
            let dictTemp = dictResponse!["data"]!.dictionary
            
            if let userId = dictTemp?["id"]?.stringValue {
                self.strId                  = userId
                self.strId                  = dictTemp?["id"]?.stringValue ?? ""
                self.strProfileImage        = dictTemp?["profileImage"]?.stringValue ?? ""
                self.isDND                  = dictTemp?["isDND"]?.boolValue ?? false
                self.strAboutMe             = dictTemp?["aboutme"]?.stringValue ?? ""
                self.strUserLastName        = dictTemp?["lastName"]?.stringValue ?? ""
                self.isVerify               = dictTemp?["isVerified"]?.boolValue ?? false
                self.strUserFirstName       = dictTemp?["firstName"]?.stringValue ?? ""
                self.strUserDisplayName     = dictTemp?["displayName"]?.stringValue ?? ""
                self.strUserAge             = getUserAgeFromDate(strDate: dictTemp?["dob"]?.stringValue ?? "")
                
                success(self)
            }
            else {
                failed("No user found")
            }
            
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    private func createListOfAllUsers(response: [String: AnyObject]) -> [NearByModel] {
        
        var arrNewList = [NearByModel]()
        
        let json = JSON(response as Any)
        let dictResponse = json.dictionary
        let dictTemp = dictResponse!["data"]!.dictionary
        let arrList = dictTemp!["userslist"]!.arrayValue
        
        for details in arrList {
            
            let model = NearByModel()
            
            model.strCurrentPage        = dictTemp!["current_page"]!.stringValue
            model.strTotalPage          = dictTemp!["total_page"]!.stringValue
            
            model.strUserFirstName       = details["firstName"].stringValue
            model.strDeviceType          = details["deviceType"].stringValue
            model.strUserDisplayName     = details["displayName"].stringValue
            model.strAccessToken         = details["accessToken"].stringValue
            model.strUserLastName        = details["lastName"].stringValue
            model.strDeviceToken         = details["deviceToken"].stringValue
            model.isVerify               = details["isVerified"].boolValue
            model.strUserCountry         = details["country"].stringValue
            model.strProfileImage        = details["profileImage"].stringValue
            model.strUserCity            = details["city"].stringValue
            model.distance               = "\(details["distance"].stringValue) ml"
            model.strIsCommunityUser     = details["isCommunityUser"].stringValue
            model.strEmailId             = details["emailID"].stringValue
            model.isDND                  = details["isDND"].boolValue
            model.strId                  = details["id"].stringValue
            model.strAboutMe             = details["aboutme"].stringValue
            model.strGender              = details["gender"].stringValue
            model.strUserAge             = getUserAgeFromDate(strDate: details["dob"].stringValue)
            arrNewList.append(model)
            
        }
        
        return arrNewList
        
    }
    
    func getDisplayName() -> String {
        
        if(self.strUserDisplayName != "") {
           return self.strUserDisplayName
        }
        else {
            return self.strUserFirstName + " " + self.strUserLastName
        }
    }
    
}
