//
//  SplashVC.swift
//  Fluke
//
//  Created by JP on 24/02/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftKeychainWrapper

class SplashVC: UIViewController, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    private var currentLoc: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getLocation()
        self.sendEphemeralToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getVersionDetails()
    }
    
    func sendEphemeralToken() {
        
        let otherChar = "22Oct"
        
        if let uuid = KeychainWrapper.standard.string(forKey: "email") {
            
            if(uuid != "") {
                UserModel.sharedUser.strEmailId = uuid
                UserModel.sharedUser.strPassword = KeychainWrapper.standard.string(forKey: "pass")!
                UserModel.sharedUser.strDeviceUniqId = KeychainWrapper.standard.string(forKey: "uuid")!
                print("GET EMAIL: \(UserModel.sharedUser.strEmailId)")
                print("GET PASS: \(UserModel.sharedUser.strPassword)")
                
                self.loginUser()
            }
            else {
                UserModel.sharedUser.strDeviceUniqId = (UIDevice.current.identifierForVendor?.uuidString ?? "") + otherChar
                
                if (UserModel.sharedUser.strDeviceUniqId != "") {
                    let saveSuccessful: Bool = KeychainWrapper.standard.set(UserModel.sharedUser.strDeviceUniqId, forKey: "uuid")
                    print("Save was successful: \(saveSuccessful)")
                    print("GET UUID: \(UserModel.sharedUser.strDeviceUniqId)")
                }
            }
            
        }
        else {
            
            UserModel.sharedUser.strDeviceUniqId = (UIDevice.current.identifierForVendor?.uuidString ?? "") + otherChar
            
            if (UserModel.sharedUser.strDeviceUniqId != "") {
                let saveSuccessful: Bool = KeychainWrapper.standard.set(UserModel.sharedUser.strDeviceUniqId, forKey: "uuid")
                print("Save was successful: \(saveSuccessful)")
                print("GET UUID: \(UserModel.sharedUser.strDeviceUniqId)")
            }
        }
    }
    
    
    private func getLocation() {
        
        locationManager.requestWhenInUseAuthorization()
        
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            currentLoc = locationManager.location
            
            if(currentLoc != nil) {
                UserModel.sharedUser.strLat = "\(currentLoc.coordinate.latitude)"
                UserModel.sharedUser.strLong = "\(currentLoc.coordinate.longitude)"
            }
            else {
                UserModel.sharedUser.strLat = "23.234324"
                UserModel.sharedUser.strLong = "71.234234"
            }
        }
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLoc = locations.last! as CLLocation
        UserModel.sharedUser.strLat = "\(currentLoc.coordinate.latitude)"
        UserModel.sharedUser.strLong = "\(currentLoc.coordinate.longitude)"
    }
    
    
    private func getVersionDetails() {
        
        UserModel.sharedUser.getAppVersionDetails(success: { (isForceUpdate) in
            
            if(isForceUpdate != true) {//Force update
                self.showAlertWithForceUpdate(strMsg: Constant.NewVerionsDetsil())
            }
            
        }) { (strError) in
            
        }
    }
    
    private func loginUser() {
        
        UserModel.sharedUser.loginUser(success: { (response) in
            
        }) { (strError) in
            
        }
        
    }
    
}
