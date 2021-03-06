//
//  SplashScreenVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit
import UserNotifications
import Quickblox

class SplashScreenVC: UIViewController {
    @IBOutlet weak var loginInfoLabel: UILabel!
    private var infoText = "" {
        didSet {
            loginInfoLabel.text = infoText
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let profile = Profile()
        if profile.isFull == false {
            //AppDelegate.shared.rootViewController.showLoginScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //MARK: - Reachability
        let updateLoginInfo: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            let loginInfo = notConnection ? LoginConstant.checkInternet : LoginStatusConstant.intoChat
            let profile = Profile()
            if profile.isFull == true, notConnection == false {
                self?.login(fullName: profile.fullName, login: profile.login)
            }
            self?.infoText = loginInfo
        }
        
        Reachability.instance.networkStatusBlock = { status in
            updateLoginInfo?(status)
        }
        updateLoginInfo?(Reachability.instance.networkConnectionStatus())
    }
    
    /**
        *  login
        */
       private func login(fullName: String, login: String, password: String = LoginConstant.defaultPassword) {
           QBRequest.logIn(withUserLogin: login,
                           password: password,
                           successBlock: { [weak self] response, user in
                               guard let self = self else {
                                   return
                               }
                               
                               user.password = password
                               Profile.synchronize(user)
                                self.connectToChat(user: user)
                               
               }, errorBlock: { [weak self] response in
                   //self?.handleError(response.error?.error, domain: ErrorDomain.logIn)
                   if response.status == QBResponseStatusCode.unAuthorized {
                       // Clean profile
                       Profile.clearProfile()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        //AppDelegate.shared.rootViewController.showLoginScreen()
                    }
                   }
                
           })
    }
    
    /**
     *  connectToChat
     */
    private func connectToChat(user: QBUUser) {
        infoText = LoginStatusConstant.intoChat
        QBChat.instance.connect(withUserID: user.id,
                                password: LoginConstant.defaultPassword,
                                completion: { [weak self] error in
                                    guard let self = self else { return }
                                    if let error = error {
                                        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                            // Clean profile
                                            Profile.clearProfile()
//                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) { AppDelegate.shared.rootViewController.showLoginScreen()
//                                            }
                                        }
                                        
                                    } else {
                                        self.registerForRemoteNotifications()
                                        //did Login action
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
//                                            AppDelegate.shared.rootViewController.goToDialogsScreen()
                                        }
                                    }
        })
    }
    
    private func registerForRemoteNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { granted, error in
            if let error = error {
                debugPrint("[AuthorizationViewController] registerForRemoteNotifications error: \(error.localizedDescription)")
                return
            }
            center.getNotificationSettings(completionHandler: { settings in
                if settings.authorizationStatus != .authorized {
                    return
                }
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            })
        })
    }
    
    // MARK: - Handle errors
}
