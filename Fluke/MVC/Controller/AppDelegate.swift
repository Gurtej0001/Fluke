//
//  AppDelegate.swift
//  Fluke
//
//  Created by JP on 23/02/20.
//  Copyright © 2020 JP. All rights reserved.
//

//15000
//

import UIKit
import CoreData
import UserNotifications
import Quickblox
import QuickbloxWebRTC
import CallKit
import PushKit
import GooglePlaces
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

struct CredentialsConstant {
    
    //Fluke
    static let applicationID:UInt = 82456
    static let authKey = "9ExyYGc7EPzZg8u"
    static let authSecret = "5zXwMHX86vvNBGO"
    static let accountKey = "9LFSENgdBgh1KR3Zsaht"
}

struct TimeIntervalConstant {
    static let answerTimeInterval: TimeInterval = 60.0
    static let dialingTimeInterval: TimeInterval = 5.0
}

struct AppDelegateConstant {
    static let enableStatsReports: UInt = 1
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    lazy var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    
    var window: UIWindow?
    var voipRegistry : PKPushRegistry?
    var callmanager = CallManager()
    
    var providerConfiguration: CXProviderConfiguration {
      let providerConfiguration = CXProviderConfiguration(localizedName: "Pulse Health")
      
      providerConfiguration.supportsVideo = true
      providerConfiguration.maximumCallsPerCallGroup = 1
      providerConfiguration.supportedHandleTypes = [.phoneNumber]
      
      return providerConfiguration
    }
    
    var isCalling = false {
        didSet {
            if UIApplication.shared.applicationState == .background,
                isCalling == false {
                disconnect()
            }
        }
    }
    
    var uuid = UIDevice.current.identifierForVendor?.uuidString
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        self.window?.backgroundColor = UIColor.white
        S3Manager.sharedS3Manager.initializeS3()
        
        GMSPlacesClient.provideAPIKey("AIzaSyDJXAS0gbzjTzXXHJIF54gZK2X0DlXZeg4")
        
        //QBManager.sharedManager.setupForQB()
        
        self.setupForNotification(application)
                
        QBSettings.applicationID = CredentialsConstant.applicationID;
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
        QBSettings.autoReconnectEnabled = true
        QBSettings.logLevel = QBLogLevel.debug
        QBSettings.enableXMPPLogging()
        QBRTCConfig.setAnswerTimeInterval(TimeIntervalConstant.answerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(TimeIntervalConstant.dialingTimeInterval)
        QBRTCConfig.setLogLevel(QBRTCLogLevel.verbose)
        
        if AppDelegateConstant.enableStatsReports == 1 {
            QBRTCConfig.setStatsReportTimeInterval(1.0)
        }
        
        QBRTCClient.initializeRTC()

        self.registerForRemoteNotification()
        self.voipRegistration()
        
        return true
    }
    
    func voipRegistration() {
        let mainQueue = DispatchQueue.main
        voipRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry?.delegate = self
        voipRegistry?.desiredPushTypes = [PKPushType.voIP]
    }

    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()

            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    
                }
            }

        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    private func setupForNotification(_ application: UIApplication) {
        
//        UNUserNotificationCenter.current().delegate = self

        //remote Notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, err) in
                if err != nil {
                    //Something bad happend
                } else {
                    UNUserNotificationCenter.current().delegate = self
                    Messaging.messaging().delegate = self

                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }

        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert], completionHandler: { (granted, error) in
                
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
                
            })
        }else{
            let notificationSettings = UIUserNotificationSettings(types: [.badge,.sound,.alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        
//        if #available(iOS 10.0, *) {
//
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//        } else {
//            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//
//        application.registerForRemoteNotifications()
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        UserModel.sharedUser.strFCMToken = fcmToken
    }
    
    func ConnectToFCM() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("\n\n\n\n\n ==== FCM Token:  ",fcmToken)
        UserModel.sharedUser.strFCMToken = fcmToken
        ConnectToFCM()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        print("Handle push from foreground")
        // custom code to handle push while app is in the foreground
        print("\(notification.request.content.userInfo)")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Barker"), object: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        let deviceIdentifier = identifierForVendor.uuidString
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { (response, objects) in
        }, errorBlock: { (response) in
            debugPrint("[AppDelegate] createSubscription error: \(String(describing: response.error))")
        })
        
        
        print("APNs device token: \(deviceToken)")
        
        let deviceIdentifier1: String = UIDevice.current.identifierForVendor!.uuidString
        let subscription1 = QBMSubscription()
        subscription1.notificationChannel = QBMNotificationChannel.APNSVOIP
        subscription1.deviceUDID = deviceIdentifier1
        subscription1.deviceToken = voipRegistry?.pushToken(for: PKPushType.voIP)
                
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Logging out from chat.
        if isCalling == false {
            disconnect()
        }
        
        UserModel.sharedUser.userOnlineOffline(strStatus: "False", success: { (response) in
        }) { (strError) in
        }
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Logging in to chat.
        if QBChat.instance.isConnected == true {
            return
        }
        connect { (error) in

        }
        
        
        UserModel.sharedUser.userOnlineOffline(strStatus: "True", success: { (response) in
        }) { (strError) in
        }
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Logging out from chat.
        disconnect()
        
        UserModel.sharedUser.userOnlineOffline(strStatus: "False", success: { (response) in
        }) { (strError) in
        }
        
    }
    
    //MARK: - Connect/Disconnect
    func connect(completion: QBChatCompletionBlock? = nil) {
        let currentUser = Profile()
        
        guard currentUser.isFull == true else {
            completion?(NSError(domain: LoginConstant.chatServiceDomain,
                                code: LoginConstant.errorDomaimCode,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Please enter your login and username."
                ]))
            return
        }
        
        if QBChat.instance.isConnected == true {
            completion?(nil)
        } else {
            QBSettings.autoReconnectEnabled = true
            QBChat.instance.connect(withUserID: currentUser.ID, password: currentUser.password, completion: completion)
        }
        
        UserModel.sharedUser.userOnlineOffline(strStatus: "True", success: { (response) in
        }) { (strError) in
        }
        
    }
    
    func disconnect(completion: QBChatCompletionBlock? = nil) {
        
        UserModel.sharedUser.userOnlineOffline(strStatus: "False", success: { (response) in
        }) { (strError) in
        }
        
        QBChat.instance.disconnect(completionBlock: completion)
    }
    
}

extension String {
    
    func localized(_ lang:String) ->String {
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}

















extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        if(type == .voIP) {
            
            let deviceIdentifier1: String = UIDevice.current.identifierForVendor!.uuidString
            let subscription1 = QBMSubscription()
            subscription1.notificationChannel = QBMNotificationChannel.APNSVOIP
            subscription1.deviceUDID = deviceIdentifier1
            subscription1.deviceToken = voipRegistry?.pushToken(for: PKPushType.voIP)
            
//            QBRequest.createSubscription(subscription1, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
//                //
//            }) { (response: QBResponse!) -> Void in
//                //
//            }
        }
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
            debugPrint("[UsersViewController] Unregister Subscription request - Success")
        }, errorBlock: { error in
            debugPrint("[UsersViewController] Unregister Subscription request - Error")
        })
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

                                        }
                                    } else {
                                        //did Login action
                                        //SVProgressHUD.dismiss()
                                    }
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        guard type == .voIP else { return }
        
        if payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
            let application = UIApplication.shared
            if application.applicationState == .background && appDelegate.backgroundTask == .invalid {
                appDelegate.backgroundTask = application.beginBackgroundTask(expirationHandler: {
                    application.endBackgroundTask(appDelegate.backgroundTask)
                    appDelegate.backgroundTask = UIBackgroundTaskIdentifier.invalid
                })
            }
            if QBChat.instance.isConnected == false {
                connectToChat()
            }
        }
        
//        let provider = CXProvider(configuration: providerConfiguration)
//        let uuidString = payload.dictionaryPayload["UDID"] as? String
//        let uuid = UUID(uuidString: "\(uuidString!)")
//        let handle = payload.dictionaryPayload["handle"] as! String
//
//
//        let update = CXCallUpdate()
//        update.remoteHandle = CXHandle(type: .generic, value: handle)
//        update.hasVideo = false
//
//        provider.reportNewIncomingCall(with: uuid!, update: update) { error in
//            if error == nil {
//                let call = Call(uuid: uuid!, handle: handle)
//                self.callmanager.add(call: call)
//            }
//        }
        
    }
        
    /// Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        print("START CALL")
        //providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }
}



enum CallState {
  case connecting
  case active
  case held
  case ended
}

enum ConnectedState {
  case pending
  case complete
}


class Call: NSObject {
  
  let uuid: UUID
  let outgoing: Bool
  let handle: String
  
  var state: CallState = .ended {
    didSet {
      stateChanged?()
    }
  }
  
  var connectedState: ConnectedState = .pending {
    didSet {
      connectedStateChanged?()
    }
  }
  
  var stateChanged: (() -> Void)?
  var connectedStateChanged: (() -> Void)?
  
  init(uuid: UUID, outgoing: Bool = false, handle: String) {
    self.uuid = uuid
    self.outgoing = outgoing
    self.handle = handle
  }
  
  func start(completion: ((_ success: Bool) -> Void)?) {
    completion?(true)

    DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 3) {
      self.state = .connecting
      self.connectedState = .pending
      
      DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1.5) {
        self.state = .active
        self.connectedState = .complete
      }
    }
  }
  
  func answer() {
    state = .active
  }
  
  func end() {
    state = .ended
  }

}

class CallManager: NSObject {
  
  var callsChangedHandler: (() -> Void)?
  
   var calls = [Call]()
   let callController = CXCallController()
  
  func startCall(handle: String, videoEnabled: Bool) {
    let handle = CXHandle(type: .phoneNumber, value: handle)
    let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
    startCallAction.isVideo = videoEnabled
    let transaction = CXTransaction(action: startCallAction)
    
    requestTransaction(transaction)
  }
  
  func end(call: Call) {
    let endCallAction = CXEndCallAction(call: call.uuid)
    let transaction = CXTransaction(action: endCallAction)
    requestTransaction(transaction)
  }
  
  func setHeld(call: Call, onHold: Bool) {
    let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
    let transaction = CXTransaction()
    transaction.addAction(setHeldCallAction)
    
    requestTransaction(transaction)
  }
  
  private func requestTransaction(_ transaction: CXTransaction) {
    callController.request(transaction) { error in
      if let error = error {
        print("Error requesting transaction: \(error)")
      } else {
        print("Requested transaction successfully")
      }
    }
  }
  
  func callWithUUID(uuid: UUID) -> Call? {
    guard let index = calls.index(where: { $0.uuid == uuid }) else {
      return nil
    }
    return calls[index]
  }
  
  func add(call: Call) {
    calls.append(call)
    call.stateChanged = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.callsChangedHandler?()
    }
    callsChangedHandler?()
  }
  
  func remove(call: Call) {
    guard let index = calls.index(where: { $0 === call }) else { return }
    calls.remove(at: index)
    callsChangedHandler?()
  }
  
  func removeAllCalls() {
    calls.removeAll()
    callsChangedHandler?()
  }
}
