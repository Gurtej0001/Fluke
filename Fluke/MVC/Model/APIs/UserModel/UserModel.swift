//
//  UserModel.swift
//  Fluke
//
//  Created by JP on 29/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class UserModel: NSObject {
    
    var strId = ""
    
    var strUserFirstName = ""
    var strUserLastName = ""
    var strUserDisplayName = ""
    var strEmailId = ""
    var strPassword = ""
    var strGender = ""
    var strAgeorDOB = ""
    var strAboutMe = ""
    var strPlanId = "0"
    var strUserCountry = ""
    var strUserCity = ""
    var strDeviceUniqId = ""
    var strDeviceType = ""
    var isVerify = false
    var strIsCommunityUser = ""
    var strDeviceToken = ""
    var strAccessToken = ""
    var strLat = "23.24334"
    var strLong = "72.345435"
    var strPostCode = "345543"
    var isDND = false
    var strProfileImage = ""
    var strFCMToken = "A"
    var strEmailVerifiedStatus = ""
    var strPhotoIDVerifiedStatus = ""
    var strPhotoPhotoURL = ""
    var isOnline = false
    var strCurrentPage = ""
    var strTotalPage = ""
    
    var strBlockedByUserID = ""
    var strBlockedUserID = ""
    var strBlockedID = ""
    
    static var sharedUser: UserModel = {
        let user = UserModel()
        return user
    }()
    
    
    func getAppVersionDetails(success:@escaping (Bool) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIGetVersion)
        let dictParam = [String:String]()
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            let json = JSON(response as Any)
            let dictResponse = json.dictionary
            let arrList = dictResponse!["data"]!.arrayValue
            
            for (_, details) in arrList.enumerated() {
                
                if(details["appType"].stringValue == Constant.AppType()) {
                    success(details["updateOption"].boolValue)
                    break
                }
            }
            
            success(true)
            
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    func registerNewUser(success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIRegister)
        let dictParam = ["firstName":UserModel.sharedUser.strUserFirstName,
                         "lastName":UserModel.sharedUser.strUserLastName,
                         "displayName":UserModel.sharedUser.strUserDisplayName,
                         "emailID":UserModel.sharedUser.strEmailId,
                         "gender":UserModel.sharedUser.strGender,
                         "dob":UserModel.sharedUser.strAgeorDOB,
                         "aboutme":UserModel.sharedUser.strAboutMe,
                         "country":UserModel.sharedUser.strUserCountry,
                         "city":UserModel.sharedUser.strUserCity,
                         "deviceID":UserModel.sharedUser.strDeviceUniqId,
                         "deviceType":Constant.AppType(),
                         "deviceToken":UserModel.sharedUser.strDeviceToken,
                         "latitude":UserModel.sharedUser.strLat,
                         "longitude":UserModel.sharedUser.strLong,
                         "profileImage":UserModel.sharedUser.strProfileImage,
                         "password":UserModel.sharedUser.strPassword,
                         "postcode":UserModel.sharedUser.strPostCode]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: true, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            self.setUserDetailsForRegister(response: response!)
            
            KeychainWrapper.standard.set(UserModel.sharedUser.strEmailId, forKey: "email")
            KeychainWrapper.standard.set(UserModel.sharedUser.strPassword, forKey: "pass")
            
            success(self)
            
        }) { (strError) in
            failed(strError!)
        }
        
    }
    
    func contactUsMsg(strSubject:String, strDesc:String, success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIContactUsMsg)
        let dictParam = ["subject":strSubject,
                         "message":strDesc]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: true, apiURL: url!, dictParam: dictParam, success: { (response) in
            success(self)
        }) { (strError) in
            failed(strError!)
        }
        
    }
    
    func updateUser(success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIEditProfile)
        
        let dictParam = ["firstName":UserModel.sharedUser.strUserFirstName,
                         "lastName":UserModel.sharedUser.strUserLastName,
                         "displayName":UserModel.sharedUser.strUserDisplayName,
                         "emailID":UserModel.sharedUser.strEmailId,
                         "gender":UserModel.sharedUser.strGender,
                         "dob":UserModel.sharedUser.strAgeorDOB,
                         "aboutme":UserModel.sharedUser.strAboutMe,
                         "country":UserModel.sharedUser.strUserCountry,
                         "city":UserModel.sharedUser.strUserCity,
                         "profileImage":UserModel.sharedUser.strProfileImage]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: true, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            
            self.setUserDetailsForRegister(response: response!)
            success(self)
            
        }) { (strError) in
            failed(strError!)
        }
        
        
    }
    
    func changeUserPassword(strOld:String, strNew:String, success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIChangePass)
        
        let dictParam = ["oldPassword":strOld,
                         "newPassword":strNew]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            UserModel.sharedUser.strPassword = strNew
            KeychainWrapper.standard.set(strNew, forKey: "pass")
            success(self)
            
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func loginUser(success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APILogin)
        
        let dictParam = ["deviceToken":UserModel.sharedUser.strFCMToken,
                         "emailID":UserModel.sharedUser.strEmailId,
                         "password":UserModel.sharedUser.strPassword,
                         "latitude":UserModel.sharedUser.strLat,
                         "longitude":UserModel.sharedUser.strLong]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            self.setUserDetailsForLogin(response: response!)
            
            KeychainWrapper.standard.set(UserModel.sharedUser.strEmailId, forKey: "email")
            KeychainWrapper.standard.set(UserModel.sharedUser.strPassword, forKey: "pass")
            
            success(self)
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func forgotPass(strEmail:String, success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIForgotPass)
        
        let dictParam = ["emailID":strEmail]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            success(self)
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func logoutUser(success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APILogout)
        let dictParam = [String:String]()
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            KeychainWrapper.standard.set("", forKey: "email")
            KeychainWrapper.standard.set("", forKey: "pass")
            
            success(self)
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func setDND(success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIDND)
        
        let dictParam = ["status":UserModel.sharedUser.isDND == true ? "ON" : "OFF"]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            success(self)
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func userOnlineOffline(strStatus:String, success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIOnlienOffline)
        
        let dictParam = ["status":strStatus]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            success(self)
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func verifyUser(strEmail:String?, strImageURL:String?, success:@escaping (String) -> Void, failed:@escaping (String?) -> Void) {
        
        let mainUrl: URL!
        var dictParam = [String:String]()
        
        if(strEmail != nil) {
            mainUrl = URL(string: appBaseURL + APIVerifyUserBymail)
        }
        else {
            mainUrl = URL(string: appBaseURL + APIVerifyUserByImage)
            dictParam["photoIDImage"] = strImageURL
        }
        
        if(mainUrl != nil) {
            NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: true, apiURL: mainUrl, dictParam: dictParam, success: { (response) in
                success("")
            }) { (strError) in
                failed(strError!)
            }
        }
        
    }
    
    
    func allCOuntryListForRandomSearch(success:@escaping ([String]) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APICountryList)
        
        let dictParam = [String:String]()
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            let json = JSON(response as Any)
            let dictResponse = json.dictionary
            let details = dictResponse!["data"]?.arrayValue
            
            var arrCountry = [String]()
            
            for name in details! {
                arrCountry.append("\(name)")
            }
            
            success(arrCountry)
            
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func purchasePlan(success:@escaping (String) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIPurchasePlan)
        
        let dictParam = ["planID":"1",
                         "subscriptionDetails":""]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            success("")
            
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func joinCommunity(success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIJoinCommunity)
        
        let dictParam = [String:String]()
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            UserModel.sharedUser.strIsCommunityUser = "Yes"
            success(self)
            
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func blockUser(strMsg:String, strUserId: String, success:@escaping (String) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIBlockUser)
        
        let dictParam = ["userID":strUserId,
                         "reason":strMsg]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            let json = JSON(response as Any)
            let dictResponse = json.dictionary
            let msg = dictResponse!["message"]?.stringValue
            
            success(msg ?? "User blocked")
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func unblockUser(strId: String, success:@escaping (String) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIUnBlockUser)
        
        let dictParam = ["id":strId]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            let json = JSON(response as Any)
            let dictResponse = json.dictionary
            let msg = dictResponse!["message"]!.stringValue
            
            success(msg)
        }) { (strError) in
            failed(strError!)
        }
    }
    
    func getListOfBlockedUser(strPage: String, success:@escaping ([UserModel]) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIBlockedUserList)
        let dictParam = ["page_no":strPage]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            success(self.createListOfAllUsers(response: response!))
            
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    func getContetForSlug(strSlug: String, success:@escaping (String) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIStaticContent)
        let dictParam = ["slug":strSlug]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            let json = JSON(response as Any)
            let dictResponse = json.dictionary
            let details = dictResponse!["data"]?.dictionary
            
            success(details!["content"]!.stringValue)
            
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    func getUserDetailsFor(strId:String, success:@escaping (UserModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIOtherProfile)
        
        let dictParam = ["userID":strId]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            let json = JSON(response as Any)
            let dictResponse = json.dictionary
            let details = dictResponse!["data"]?.dictionary
            
            let userDetails = UserModel()
            
            userDetails.strId                   = details!["id"]?.stringValue ?? ""
            userDetails.strUserCity             = details!["city"]?.stringValue ?? ""
            userDetails.strGender               = details!["gender"]?.stringValue ?? ""
            userDetails.strIsCommunityUser      = details!["isCommunityUser"]?.stringValue ?? ""
            userDetails.strUserCountry          = details!["country"]?.stringValue ?? ""
            userDetails.isVerify                = details!["isVerified"]?.boolValue ?? false
            userDetails.strEmailId              = details!["emailID"]?.stringValue ?? ""
            userDetails.strUserDisplayName      = details!["displayName"]?.stringValue ?? ""
            userDetails.strUserLastName         = details!["firstName"]?.stringValue ?? ""
            userDetails.strUserLastName         = details!["lastName"]?.stringValue ?? ""
            userDetails.strProfileImage         = details!["profileImage"]?.stringValue ?? ""
            userDetails.strAboutMe              = details!["aboutme"]?.stringValue ?? ""
            userDetails.strPlanId               = details!["planID"]?.stringValue ?? ""
            userDetails.isOnline                = details!["isOnline"]?.boolValue ?? false
            
            print("***************************************************")
            print(details!["isOnline"] ?? "")
            
            userDetails.strAgeorDOB             = getUserAgeFromDate(strDate: details!["dob"]?.stringValue ?? "")
            
            
            success(userDetails)
            
        }) { (strError) in
            failed(strError!)
        }
        
    }
    
    private func setUserDetailsForLogin(response: [String: AnyObject]) {
        
        let json = JSON(response as Any)
        let dictResponse = json.dictionary
        let details = dictResponse!["data"]?.dictionaryValue
        
        let userExist = details!["isuserexist"]?.boolValue
        
        if(userExist == true) {
            self.strUserFirstName           = details!["userData"]!["firstName"].stringValue
            self.strDeviceType              = details!["userData"]!["deviceType"].stringValue
            self.strUserDisplayName         = details!["userData"]!["displayName"].stringValue
            self.strAccessToken             = details!["userData"]!["accessToken"].stringValue
            self.strUserLastName            = details!["userData"]!["lastName"].stringValue
            self.strDeviceToken             = details!["userData"]!["deviceToken"].stringValue
            self.isVerify                   = details!["userData"]!["isVerified"].boolValue
            self.strUserCountry             = details!["userData"]!["country"].stringValue
            self.strProfileImage            = details!["userData"]!["profileImage"].stringValue
            self.strUserCity                = details!["userData"]!["city"].stringValue
            self.strIsCommunityUser         = details!["userData"]!["isCommunityUser"].stringValue
            self.strEmailId                 = details!["userData"]!["emailID"].stringValue
            self.isDND                      = details!["userData"]!["isDND"].boolValue
            self.strId                      = details!["userData"]!["id"].stringValue
            self.strAboutMe                 = details!["userData"]!["aboutme"].stringValue
            self.strAgeorDOB                = details!["userData"]!["dob"].stringValue
            self.strGender                  = details!["userData"]!["gender"].stringValue
            self.strEmailVerifiedStatus     = details!["userData"]!["isEmailVerified"].stringValue
            self.strPhotoIDVerifiedStatus   = details!["userData"]!["isPhotoIDVerified"].stringValue
            self.strPhotoPhotoURL           = details!["userData"]!["photoIDImage"].stringValue
            self.strPlanId                  = details!["userData"]!["planID"].stringValue
        }
    }
    
    private func setUserDetailsForRegister(response: [String: AnyObject]) {
        
        let json = JSON(response as Any)
        let details = json.dictionary
        
        self.strUserFirstName           = details!["data"]!["firstName"].stringValue
        self.strDeviceType              = details!["data"]!["deviceType"].stringValue
        self.strUserDisplayName         = details!["data"]!["displayName"].stringValue
        self.strAccessToken             = details!["data"]!["accessToken"].stringValue
        self.strUserLastName            = details!["data"]!["lastName"].stringValue
        self.strDeviceToken             = details!["data"]!["deviceToken"].stringValue
        self.isVerify                   = details!["data"]!["isVerified"].boolValue
        self.strUserCountry             = details!["data"]!["country"].stringValue
        self.strProfileImage            = details!["data"]!["profileImage"].stringValue
        self.strUserCity                = details!["data"]!["city"].stringValue
        self.strIsCommunityUser         = details!["data"]!["isCommunityUser"].stringValue
        self.strEmailId                 = details!["data"]!["emailID"].stringValue
        self.isDND                      = details!["data"]!["isDND"].boolValue
        self.strId                      = details!["data"]!["id"].stringValue
        self.strAboutMe                 = details!["data"]!["aboutme"].stringValue
        self.strAgeorDOB                = details!["data"]!["dob"].stringValue
        self.strGender                  = details!["data"]!["gender"].stringValue
        self.strEmailVerifiedStatus     = details!["data"]!["isEmailVerified"].stringValue
        self.strPhotoIDVerifiedStatus   = details!["data"]!["isPhotoIDVerified"].stringValue
        self.strPhotoPhotoURL           = details!["data"]!["photoIDImage"].stringValue
        self.strPlanId                  = details!["data"]!["planID"].stringValue
        
    }
    
    private func createListOfAllUsers(response: [String: AnyObject]) -> [UserModel] {
        
        var arrNewList = [UserModel]()
        
        let json = JSON(response as Any)
        let dictResponse = json.dictionary
        let dictTemp = dictResponse!["data"]!.dictionary
        let arrList = dictTemp!["blocklist"]!.arrayValue
        
        for details in arrList {
            
            let model = UserModel()
            
            model.strCurrentPage        = dictTemp!["current_page"]!.stringValue
            model.strTotalPage          = dictTemp!["total_page"]!.stringValue
            
            model.strBlockedUserID    = details["blockedUserID"].stringValue
            model.strBlockedByUserID    = details["blockedByUserID"].stringValue
            model.strBlockedID    = details["id"].stringValue
            
            let tempDi = details["users"].dictionaryValue
            
            model.strUserDisplayName    = tempDi["displayName"]!.stringValue
            model.strUserFirstName    = tempDi["firstName"]!.stringValue
            model.strUserLastName    = tempDi["lastName"]!.stringValue
            model.strProfileImage       = tempDi["profileImage"]!.stringValue
            
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
