
import Quickblox
import UIKit
import SVProgressHUD


class QBManager: NSObject {
    
    static var sharedManager: QBManager = {
        let manager = QBManager()
        return manager
    }()
    
    var myUser: QBUUser!
    
    func signUp(fullName: String, login: String) {
        
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = fullName
        newUser.password = LoginConstant.defaultPassword
        
        let customDetails = ["profileImage":UserModel.sharedUser.strProfileImage,
                             "planID":"0",
                             "isDND":"\(UserModel.sharedUser.isDND)",
                             "userId":UserModel.sharedUser.strId]
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(customDetails) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                newUser.customData = jsonString
            }
        }
        
        
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            
            self?.login(fullName: fullName, login: login)
            
            }, errorBlock: { [weak self] response in
                
                if response.status == QBResponseStatusCode.validationFailed {
                    // The user with existent login was created earlier
                    self?.login(fullName: fullName, login: login)
                    return
                }
        })
    }
    
    
    private func login(fullName: String, login: String, password: String = LoginConstant.defaultPassword) {
        
        QBRequest.logIn(withUserLogin: login, password: password, successBlock: { [weak self] response, user in
            
            self!.myUser = user
            
            user.password = password
            user.updatedAt = Date()
            Profile.synchronize(user)
            
            if user.fullName != fullName {
                self?.updateFullName(fullName: fullName)
            } else {
                self?.connectToChat(user: user)
            }
            
            }, errorBlock: { response in
                
                if response.status == QBResponseStatusCode.unAuthorized {
                    // Clean profile
                    Profile.clearProfile()
                    
                }
        })
    }
    
    private func connectUser(_ user: QBUUser) {
        Profile.synchronize(user)
        connectToChat(user: user)
    }
    
    
    func updateFullName(fullName: String) {
        
        let updateUserParameter = QBUpdateUserParameters()
        updateUserParameter.fullName = fullName
        
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: {  [weak self] response, user in
            
            user.updatedAt = Date()
            Profile.update(user)
            self?.connectToChat(user: user)
            
            }, errorBlock: { response in
                
        })
    }
    
    private func connectToChat(user: QBUUser) {
        
        QBChat.instance.connect(withUserID: user.id, password: LoginConstant.defaultPassword, completion: { error in
            if let error = error {
                if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                    Profile.clearProfile()
                }
                else {
                }
            }
            else {
                QBChat.instance.pingServer(withTimeout: 0.5) { (time, isSucess) in
                }
                
            }
        })
    }
    
    
    func getListOfRecentChat(forSearch:Bool, success:@escaping ([String:Any]) -> Void, failed:@escaping (String?) -> Void) {
        
        let extendedRequest = ["sort_desc" : "_id"]
        let page = QBResponsePage(limit: 10000, skip: 0)
        
        QBRequest.dialogs(for: page, extendedRequest: extendedRequest, successBlock: { (response, dialogs, dialogUserId, page) in
            
            var arrListing = [QBChatDialog]()
            var arrUsers = [QBUUser]()
            var arrIds  = [String]()
            
            for detail in dialogs {
                
                if(forSearch == true) {
                    
                    arrListing.append(detail)
                    
                    let arrOpIds = detail.occupantIDs
                    
                    for id in arrOpIds! {
                        if(NSNumber(value: self.myUser.id) != id) {
                            arrIds.append("\(id)")
                            break
                        }
                    }
                }
                else {
                    if let _ = detail.lastMessageText {
                        
                        arrListing.append(detail)
                        
                        let arrOpIds = detail.occupantIDs
                        
                        for id in arrOpIds! {
                            if(NSNumber(value: self.myUser.id) != id) {
                                arrIds.append("\(id)")
                                break
                            }
                        }
                    }
                }
            }
            
            QBRequest.users(withIDs: arrIds, page: nil, successBlock: { (respomse, page, arrAllUsers) in
                
                for details in arrAllUsers {
                    if(details.login != UserModel.sharedUser.strId) {
                        arrUsers.append(details)
                    }
                }
                
                var arrTempUsers = [QBUUser]()
                
                for idNumber in arrIds {
                    
                    for userDetails in arrUsers {
                        
                        
                        if("\(userDetails.id)" == idNumber) {
                            arrTempUsers.append(userDetails)
                            break
                        }
                    }
                }
                
                let dict = [Constant.ChatDialogDetails.OtherUser(): arrTempUsers,
                            Constant.ChatDialogDetails.ChatDialog():arrListing] as [String : Any]
                success(dict as [String : Any])
                
            }) { (response) in
                
            }
            
        }) { (strError) in
            print(strError as Any)
        }
    }
    
//    func updateUser() {
//
//        let updateParameters = QBUpdateUserParameters()
//
//        let customDetails = ["profileImage":UserModel.sharedUser.strProfileImage,
//                             "isDND":"\(UserModel.sharedUser.isDND)",
//            "planID":"0",
//            "userId":UserModel.sharedUser.strId]
//
//        let encoder = JSONEncoder()
//        if let jsonData = try? encoder.encode(customDetails) {
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                updateParameters.customData = jsonString
//            }
//        }
//
//        QBRequest.updateCurrentUser(updateParameters, successBlock: { (response, user) in
//
//        }) { (response) in
//
//        }
//
//    }
    
    func updateUserPlanId(strPlanId: String) {
        
        let updateParameters = QBUpdateUserParameters()
        
        let customDetails = ["profileImage":UserModel.sharedUser.strProfileImage,
                             "isDND":"\(UserModel.sharedUser.isDND)",
            "planID":strPlanId,
            "userId":UserModel.sharedUser.strId]
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(customDetails) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                updateParameters.customData = jsonString
            }
        }
        
        QBRequest.updateCurrentUser(updateParameters, successBlock: { (response, user) in
            
        }) { (response) in
            
        }
        
    }
    
    func updateUserDND(strDNDStatus: String, strPlanId: String) {
        
        let updateParameters = QBUpdateUserParameters()
        
        let customDetails = ["profileImage":UserModel.sharedUser.strProfileImage,
                             "isDND":strDNDStatus,
            "planID":strPlanId,
            "userId":UserModel.sharedUser.strId]
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(customDetails) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                updateParameters.customData = jsonString
            }
        }
        
        QBRequest.updateCurrentUser(updateParameters, successBlock: { (response, user) in
            
        }) { (response) in
            
        }
        
    }
    
    func createChatDialog(strUserId: String, success:@escaping ([String:Any]) -> Void, failed:@escaping (String?) -> Void) {
        
        QBRequest.user(withLogin: strUserId, successBlock: { (response, userDetails) in
            
            var chatDialog:QBChatDialog!
            chatDialog = QBChatDialog(dialogID: nil, type: .private)
            chatDialog.occupantIDs = [NSNumber(value: userDetails.id)]
            
            QBRequest.createDialog(chatDialog, successBlock: {(response: QBResponse?, createdDialog: QBChatDialog?) in
            
                self.getListOfRecentChat(forSearch:true, success: { (dict) in
                    
                    let arrList = dict[Constant.ChatDialogDetails.ChatDialog()] as! [QBChatDialog]
                    let arrUserList = dict[Constant.ChatDialogDetails.OtherUser()] as! [QBUUser]
                    
                    var iscreated = false
                    
                    for (index, details) in arrUserList.enumerated() {
                        
                        print(details.login as Any)
                        print(strUserId as Any)
                        
                        if(details.login! == strUserId) {
                        
                            iscreated = true
                            let dict = [Constant.ChatDialogDetails.OtherUser(): details,
                                        Constant.ChatDialogDetails.ChatDialog():arrList[index]]
                            success(dict as [String : Any])
                            
                            break
                        }
                        
                    }
                    
                    if(iscreated == false) {
                        let dict = [Constant.ChatDialogDetails.OtherUser(): createdDialog?.id as Any,
                                    Constant.ChatDialogDetails.ChatDialog():createdDialog] as [String : Any]
                        success(dict)
                    }
                    
                }) { (strError) in
                    
                }
                
                
            }, errorBlock: {(response: QBResponse!) in
                
            })
            
        }) { (error) in
            
        }
    }
    
    func sendMessageTODialog(strMsg: String, isMedia: Bool, dialog:QBChatDialog) {
        
        let message: QBChatMessage = QBChatMessage()
        message.text = strMsg
        
        if(isMedia == true) {
            let attachment = QBChatAttachment()
            message.attachments = [attachment]
        }
        
        let params : NSMutableDictionary = NSMutableDictionary()
        params["save_to_history"] = true
        message.customParameters = params
        
        dialog.send(message) { (strErro) in
            print(strErro as Any)
        }
        
    }
    
    func getListOfAllMessages(strDialogId: String, success:@escaping ([QBChatMessage]) -> Void, failed:@escaping (String?) -> Void) {
        
        QBRequest.messages(withDialogID: strDialogId, extendedRequest: nil, for: nil, successBlock: { (response, arrMessages, responsePage) in
            success(arrMessages)
        }) { (response) in
            failed("No messages")
        }
    }
    
}


extension QBManager: QBChatDelegate {
    
    func chatDidReceive(_ message: QBChatMessage) {
        print(message)
    }
    
}
