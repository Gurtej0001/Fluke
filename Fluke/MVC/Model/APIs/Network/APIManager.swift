//
//  NetworkManager.swift
//  Where
//
//  Created by JP on 4/11/17.
//  Copyright © 2017 JP. All rights reserved.
//

import UIKit
import SVProgressHUD

let TIME_OUT_INTERVAL = 30

enum MediaTypeForUpload {
    case image
    case video
    case audio
}

class NetworkManager: NSObject {
    
    static let BaseRequestSharedInstance = NetworkManager()
    var taskPost: URLSessionTask? = nil
    
    private let strKeyValue = "TWl0ZXNoUGF0ZWwtRGlhYmV0ZXNBcHAtOS0xLTIwMTg"
    private let strXAPIKey = "x-api"
    
    func POSTRequset(isProgress:Bool, apiURL: URL, dictParam:[String:Any], success:@escaping ([String: AnyObject]?) -> Void, failed:@escaping (String?) -> Void) {
        
        if(isProgress == true) {
            SVProgressHUD.show()
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        print("URL: \(apiURL)")
        print("PARAM: \(dictParam)")
        
        let serviceUrl = apiURL
        var request = URLRequest(url: serviceUrl)
        
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        request.setValue(strKeyValue, forHTTPHeaderField: strXAPIKey)
        
        if(UserModel.sharedUser.strAccessToken != "") {
            request.setValue(UserModel.sharedUser.strAccessToken, forHTTPHeaderField: "accessToken")
            request.setValue(UserModel.sharedUser.strId, forHTTPHeaderField: "userID")
        }
        
        print("HEADER: \(String(describing: request.allHTTPHeaderFields))")
        
                
        guard let httpBody = try? JSONSerialization.data(withJSONObject: dictParam as Any, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if((error) != nil) {
                SVProgressHUD.dismiss()
                failed(Constant.TryAgain())
            }
            else {
                
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                
                if let data = data {
                    
                    let json = JSON(data as Any)
                    let dictResponse = json.dictionary
                    print(dictResponse as Any)
                    
                    if(dictResponse != nil) {
                        if(dictResponse!["status"]?.stringValue == "201") {
                            failed(dictResponse!["message"]?.stringValue)
                        }
                        else {
                            success((dictResponse! as [String : AnyObject]))
                        }
                    }
                    else {
                        failed(Constant.TryAgain())
                    }
                }
                else {
                    failed(Constant.TryAgain())
                }
            }
            
            }.resume()
        
    }
    
    func GETRequset(isProgress:Bool, apiURL: URL, success:@escaping ([String: AnyObject]?) -> Void, failed:@escaping (String?) -> Void) {
        
        if(isProgress == true) {
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        print("URL: \(apiURL)")
        
        let serviceUrl = apiURL
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        request.setValue(strKeyValue, forHTTPHeaderField: strXAPIKey)
        
        if(UserModel.sharedUser.strAccessToken != "") {
            request.setValue(UserModel.sharedUser.strAccessToken, forHTTPHeaderField: "accessToken")
            request.setValue(UserModel.sharedUser.strId, forHTTPHeaderField: "userID")
        }
        
        print("HEADER: \(String(describing: request.allHTTPHeaderFields))")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if((error) != nil) {
                SVProgressHUD.dismiss()
                failed(Constant.TryAgain())
            }
            else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let data = data {
                    
                    let json = JSON(data as Any)
                    let dictResponse = json.dictionary
                    print(dictResponse as Any)
                    
                    if(dictResponse != nil) {
                        
                        if(dictResponse!["status"]?.stringValue == "201") {
                            failed(dictResponse!["message"]?.stringValue)
                        }
                        else {
                            success((dictResponse! as [String : AnyObject]))
                        }
                    }
                    else {
                        failed(Constant.TryAgain())
                    }
                }
                else {
                    failed(Constant.TryAgain())
                }
            }
            
            }.resume()
        
    }
    
    //MARK:- UPLOAD MULTIPLE IMAGES
    
    func POSTWithMultipleImagesRequset(isProgress:Bool, apiURL: URL, dictParam:[String:Any], mediaData:[Data]?, mediaType:MediaTypeForUpload?, strKey:String?, success:@escaping ([String: AnyObject]?) -> Void, failed:@escaping (String?) -> Void) {
        
        if(isProgress == true) {
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }

        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        print("URL: \(apiURL)")
        print("PARAM: \(dictParam)")
        
        var request: URLRequest!
        
        do {
            request = try createRequest(apiURL:apiURL, parameters: dictParam, medaiData: mediaData, mediaType: mediaType, strKey: strKey)
        } catch {
            print(error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if((error) != nil) {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                failed(Constant.TryAgain())
            }
            else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let data = data {
                    
                    let json = JSON(data as Any)
                    let dictResponse = json.dictionary
                    print(dictResponse as Any)
                    
                    if(dictResponse != nil) {
                        
                        if(dictResponse!["status"]?.stringValue == "201") {
                                failed(dictResponse!["message"]?.stringValue)
                        }
                        else {
                            success((dictResponse! as [String : AnyObject]))
                        }
                    }
                    else {
                        failed(Constant.TryAgain())
                    }
                }
                else {
                    failed(Constant.TryAgain())
                }
            }

        }

        task.resume()
    }
    
    private func createRequest(apiURL: URL, parameters:[String:Any], medaiData: [Data]?, mediaType:MediaTypeForUpload?, strKey:String?) throws -> URLRequest {
        
        var myMedia = [Data]()
        
        let boundary = generateBoundaryString()
        let url = apiURL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(strKeyValue, forHTTPHeaderField: strXAPIKey)
        
        if(UserModel.sharedUser.strAccessToken != "") {
            request.setValue(UserModel.sharedUser.strAccessToken, forHTTPHeaderField: "accessToken")
            request.setValue(UserModel.sharedUser.strId, forHTTPHeaderField: "userID")
        }
        
        print("HEADER: \(String(describing: request.allHTTPHeaderFields))")
        
        if(medaiData != nil) {
            
            for data in medaiData! {
                myMedia.append(data)
            }
        }
        
        request.httpBody = try createBody(with: parameters, filePathKey: strKey ?? "", mediaData: myMedia, mediaType: mediaType, boundary: boundary)
        
        return request
    }
    
    private func createBody(with parameters: [String: Any]?, filePathKey: String, mediaData: [Data], mediaType:MediaTypeForUpload?, boundary: String) throws -> Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        for (i, dataOfMedao) in mediaData.enumerated() {
            let partName = "media-\(i)"
            var partFilename = "\(partName)"
            
            if(mediaType == .image) {
                partFilename = "\(partFilename).png"
            }
            else if(mediaType == .audio) {
                partFilename = "\(partFilename).mp3"
            }
            else if(mediaType == .video) {
                partFilename = "\(partFilename).mp4"
            }
            
            let mimetype = "application/octet-stream"
            
            // Write boundary header
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(partFilename)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(dataOfMedao)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    private func forceLogout() {
        
        print("Force logout")
//        DBManager.sharedManager.deleteUserInDB()
//
//        DispatchQueue.main.async {
//
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//            let appMainNavigation = storyBoard.instantiateViewController(withIdentifier: "AppMainNavigation") as! AppMainNavigation
//            appDelegate.window?.rootViewController = appMainNavigation
//        }
    }
}

extension Data {
    
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
