//
//  S3Manager.swift
//  Fluke
//
//  Created by JP on 03/05/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore

class S3Manager {
    
    static var sharedS3Manager: S3Manager = {
        let s3Manager = S3Manager()
        return s3Manager
    }()
    
    let bucketName = "flukeapp"
    let acceeKey = "AKIAYQOL3VSPODNWHERA"
    let secrateKey = "vBOImH7/+jRyo4hrXAR8V7EJV7ehNkBOmrh1FkZ5"
    let poolId = "eu-west-2:d215119a-ed2d-4b9b-af1c-b672a2894dfd"
    

    func initializeS3() {

        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .EUWest2,
            identityPoolId: poolId
        )
        
        let configuration = AWSServiceConfiguration(region: .EUWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func uploadFile(with data: Data, type: String, folderName:String ,success:@escaping (String) -> Void, failed:@escaping (String?) -> Void) {   //1
        
        let imageName = folderName + self.randomString(length: 25) + ".jpg"
        let transferManager = AWSS3TransferUtility.default()
        
        transferManager.uploadData(data, bucket: bucketName, key: imageName, contentType: type, expression: nil) { (task, error) in
            if(error == nil) {
                print(task)
                success("https://flukeapp.s3.eu-west-2.amazonaws.com/" + imageName)
            }
        }
    }

    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

}
