//
//  CallModel.swift
//  Fluke
//
//  Created by JP on 10/05/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class CallModel: NSObject {
    
    var strId = ""
    var strCallerId = ""
    var strReceiverId = ""
    var strCalldateAndTime = ""
    var strCallDuration = ""
    var strStatus = ""
    
    var callerUser = NearByModel()
    var reciverUser = NearByModel()
    
    var strCurrentPage = ""
    var strTotalPage = ""
    
    
    
    
    
    
    func addUserCallLog(status:String, callDuration: String, receiverUserID: String, success:@escaping (CallModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIAddUserCall)
        let dictParam = ["status":status,
                         "callDuration":callDuration,
                         "receiverUserID":receiverUserID]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
                success(self)
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    
    func getCallLogHistory(strPage: String, success:@escaping ([CallModel]) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APICallHistory)
        let dictParam = ["page_no":strPage]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            
            success(self.createListOfCalls(response: response!))
            
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    
    private func createListOfCalls(response: [String: AnyObject]) -> [CallModel] {
        
        var arrNewList = [CallModel]()
        
        let json = JSON(response as Any)
        let dictResponse = json.dictionary
        let dictTemp = dictResponse!["data"]!.dictionary
        let arrList = dictTemp!["callLogslist"]!.arrayValue
        
        for details in arrList {
            
            let model = CallModel()
            
            model.strCurrentPage                = dictTemp!["current_page"]!.stringValue
            model.strTotalPage                  = dictTemp!["total_page"]!.stringValue
            
            model.strId                         = details["id"].stringValue
            model.strCallerId                   = details["callerUserID"].stringValue
            model.strReceiverId                 = details["receiverUserID"].stringValue
            model.strCallDuration               = details["callDuration"].stringValue
            model.strStatus                     = details["status"].stringValue
            
            model.strCalldateAndTime            = UTCToLocal(date: details["callDateTime"].stringValue, currentormate: "yyyy-MM-dd HH:mm:ss", newformate: "yyyy-MM-dd HH:mm:ss")
            
            let callerDetails                   = details["caller_users"].dictionaryValue
            model.callerUser.strId              = callerDetails["id"]?.stringValue ?? ""
            model.callerUser.strUserFirstName   = callerDetails["firstName"]?.stringValue ?? ""
            model.callerUser.strUserLastName    = callerDetails["lastName"]?.stringValue ?? ""
            model.callerUser.strUserDisplayName = callerDetails["displayName"]?.stringValue ?? ""
            model.callerUser.strProfileImage    = callerDetails["profileImage"]?.stringValue ?? ""
            model.callerUser.isDND              = callerDetails["isDND"]?.boolValue ?? false
            
            
            let receiverDetails                  = details["receiver_users"].dictionaryValue
            model.reciverUser.strId              = receiverDetails["id"]?.stringValue ?? ""
            model.reciverUser.strUserFirstName   = receiverDetails["firstName"]?.stringValue ?? ""
            model.reciverUser.strUserLastName    = receiverDetails["lastName"]?.stringValue ?? ""
            model.reciverUser.strUserDisplayName = receiverDetails["displayName"]?.stringValue ?? ""
            model.reciverUser.strProfileImage    = receiverDetails["profileImage"]?.stringValue ?? ""
            model.reciverUser.isDND              = receiverDetails["isDND"]?.boolValue ?? false
            
            
            arrNewList.append(model)
            
        }
        
        return arrNewList
        
    }
    
}
