//
//  CallExtention.swift
//  Fluke
//
//  Created by JP on 09/05/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import PushKit

class CallExtention: UIViewController {
    
    private weak var session: QBRTCSession?
    private var callUUID: UUID?
    private var objCallModel = CallModel()
    
    lazy private var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource()
        return dataSource
    }()
    
    lazy private var navViewController: UINavigationController = {
        let navViewController = UINavigationController()
        return navViewController
        
    }()
    
    lazy private var voipRegistry: PKPushRegistry = {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        return voipRegistry
    }()
    
    
    
    func configQB() {
        QBRTCClient.instance().add(self)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
    }
    
    
    func setCallwithUser(with conferenceType: QBRTCConferenceType, chatDialog: QBChatDialog, otherUserId: String) {
        
        let callType:QBRTCConferenceType = conferenceType
        
        if hasConnectivity() {
            
            CallPermissions.check(with: callType) { granted in
                if granted {
                    
                    let ids:[NSNumber] = chatDialog.occupantIDs!
                    
                    let session = QBRTCClient.instance().createNewSession(withOpponents: ids, with: callType)
                    
                    if session.id.isEmpty == false {
                        
                        self.session = session
                        let uuid = UUID()
                        self.callUUID = uuid
                        
                        CallKitManager.instance.startCall(withUserIDs: ids, session: session, uuid: uuid)
                        
                        let storyboard = UIStoryboard(name: "Call", bundle: nil)
                        let callViewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
                        
                        callViewController.otherUserId = otherUserId
                        callViewController.callEndDelegate = self
                        callViewController.session = self.session
                        callViewController.usersDataSource = self.dataSource
                        callViewController.callUUID = uuid
                        
                        self.tabBarController?.present(callViewController, animated: false, completion: nil)
                        
                        
                        let profile = Profile()
                        guard profile.isFull == true else {
                            return
                        }
                        
                        let payload = ["message": "\(appName) is calling you.",
                            "ios_voip": "1", UsersConstant.voipEvent: "1"]
                        
                        let data = try? JSONSerialization.data(withJSONObject: payload,
                                                               options: .prettyPrinted)
                        var message = ""
                        if let data = data {
                            message = String(data: data, encoding: .utf8) ?? ""
                        }
                        let event = QBMEvent()
                        event.notificationType = QBMNotificationType.push
                        let arrayUserIDs = ids.map({"\($0)"})
                        event.usersIDs = arrayUserIDs.joined(separator: ",")
                        event.type = QBMEventType.oneShot
                        event.message = message
                        
                        let pushMessage = QBMPushMessage.init(payload: payload )
                        
                        QBRequest.sendVoipPush(pushMessage, toUsers: event.usersIDs!, successBlock: { (response, event) in
                            
                        }) { (error) in
                            
                        }
                        
                        QBRequest.createEvent(event, successBlock: { response, events in
                            debugPrint("[UsersViewController] Send voip push - Success")
                        }, errorBlock: { response in
                            debugPrint("[UsersViewController] Send voip push - Error")
                        })
                        
                    }
                }
            }
        }
        
    }
    
    // MARK: - Internal Methods
    private func hasConnectivity() -> Bool {
        
        let status = Reachability.instance.networkConnectionStatus()
        
        guard status != NetworkConnectionStatus.notConnection else {
            
            self.showAlert(strMsg: UsersAlertConstant.checkInternet)
            
            if CallKitManager.instance.isCallStarted() == false {
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("[UsersViewController] endCall")
                }
            }
            return false
        }
        return true
    }
}


extension CallExtention: CallEndDelegate {
    
    func endCallWithDurationInSecond(_ totalSeconds: String, receiverId: String) {
        
        var strStatus = ""
        
        if(totalSeconds == "0:00") {
            strStatus = "MissedCall"
        }
        else {
            strStatus = "Call"
        }
        
        objCallModel.addUserCallLog(status: strStatus, callDuration: totalSeconds, receiverUserID: receiverId, success: { (response) in
            
        }) { (strError) in
            
        }
    }
}



//MARK:- PKPushRegistry Delegate

extension CallExtention: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        if(type == .voIP) {
            
            let deviceIdentifier1: String = UIDevice.current.identifierForVendor!.uuidString
            let subscription1 = QBMSubscription()
            subscription1.notificationChannel = QBMNotificationChannel.APNSVOIP
            subscription1.deviceUDID = deviceIdentifier1
            subscription1.deviceToken = voipRegistry.pushToken(for: PKPushType.voIP)
            
            //            QBRequest.createSubscription(subscription1, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            //                //
            //            }) { (response: QBResponse!) -> Void in
            //                //
            //            }
        }
        
        let str: String = "didUpdatePushCredentials: \(pushCredentials.token)"
        print("\(str)")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        //        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
        //            return
        //        }
        //        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
        //            debugPrint("[UsersViewController] Unregister Subscription request - Success")
        //        }, errorBlock: { error in
        //            debugPrint("[UsersViewController] Unregister Subscription request - Error")
        //        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        guard type == .voIP else { return }
        
        
//        if payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
//            let application = UIApplication.shared
//            if application.applicationState == .background && appDelegate.backgroundTask == .invalid {
//                appDelegate.backgroundTask = application.beginBackgroundTask(expirationHandler: {
//                    application.endBackgroundTask(appDelegate.backgroundTask)
//                    appDelegate.backgroundTask = UIBackgroundTaskIdentifier.invalid
//                })
//            }
//            if QBChat.instance.isConnected == false {
//                connectToChat()
//            }
//        }
//
        
        
    }
    
    /// Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        print("START CALL")
        //providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }
    
}


//MARK:- QBRTCClient Delegate

extension CallExtention: QBRTCClientDelegate {
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if CallKitManager.instance.isCallStarted() == false && self.session?.id == session.id && self.session?.initiatorID == userID {
            CallKitManager.instance.endCall(with: callUUID) {
                debugPrint("[UsersViewController] endCall")
            }
            prepareCloseCall()
        }
    }
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            session.rejectCall(["reject": "busy"])
            return
        }
        
        self.session = session
        let uuid = UUID()
        callUUID = uuid
        var opponentIDs = [session.initiatorID]
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        for userID in session.opponentsIDs {
            if userID.uintValue != profile.ID {
                opponentIDs.append(userID)
            }
        }
        
        var callerName = ""
        var opponentNames = [String]()
        var newUsers = [NSNumber]()
        for userID in opponentIDs {
            
            // Getting recipient from users.
            if let user = dataSource.user(withID: userID.uintValue),
                let fullName = user.fullName {
                opponentNames.append(fullName)
            } else {
                newUsers.append(userID)
            }
        }
        
        if newUsers.isEmpty == false {
            let loadGroup = DispatchGroup()
            for userID in newUsers {
                loadGroup.enter()
                dataSource.loadUser(userID.uintValue) { (user) in
                    if let user = user {
                        opponentNames.append(user.fullName ?? user.login ?? "")
                    } else {
                        opponentNames.append("\(userID)")
                    }
                    loadGroup.leave()
                }
            }
            loadGroup.notify(queue: DispatchQueue.main) {
                callerName = opponentNames.joined(separator: ", ")
                self.reportIncomingCall(withUserIDs: opponentIDs, outCallerName: callerName, session: session, uuid: uuid)
            }
        } else {
            callerName = opponentNames.joined(separator: ", ")
            self.reportIncomingCall(withUserIDs: opponentIDs, outCallerName: callerName, session: session, uuid: uuid)
        }
    }
    
    private func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession, uuid: UUID) {
        if hasConnectivity() {
            
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs, outCallerName: outCallerName, session: session, uuid: uuid, onAcceptAction: { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                let userDetails = NearByModel()
                userDetails.strUserFirstName = outCallerName
                userDetails.strUserLastName = ""
                
                let storyboard = UIStoryboard(name: "Call", bundle: nil)
                let callViewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
                //callViewController.userDetails = userDetails
                callViewController.session = session
                callViewController.usersDataSource = self.dataSource
                callViewController.callUUID = self.callUUID
                
                self.tabBarController?.present(callViewController, animated: false, completion: nil)
                
                }, completion: { (end) in
                    debugPrint("[UsersViewController] endCall")
            })
        } else {
            
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
            if self.navViewController.presentingViewController?.presentedViewController == self.navViewController {
                self.navViewController.view.isUserInteractionEnabled = false
                self.navViewController.dismiss(animated: false)
            }
            CallKitManager.instance.endCall(with: self.callUUID) {
                debugPrint("[UsersViewController] endCall")
                
            }
            prepareCloseCall()
        }
    }
    
    private func prepareCloseCall() {
        self.callUUID = nil
        self.session = nil
        if QBChat.instance.isConnected == false {
            self.connectToChat()
        }
    }
    
    private func connectToChat() {
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        
        QBChat.instance.connect(withUserID: profile.ID,
                                password: LoginConstant.defaultPassword,
                                completion: { [weak self] error in
                                    guard let self = self else { return }
                                    if let error = error {
                                        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                            //self.logoutAction()
                                        } else {
                                            debugPrint("[UsersViewController] login error response:\n \(error.localizedDescription)")
                                        }
                                    } else {
                                        //did Login action
                                        //SVProgressHUD.dismiss()
                                    }
        })
    }
}
