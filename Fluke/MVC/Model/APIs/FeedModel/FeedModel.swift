//
//  FeedModel.swift
//  Fluke
//
//  Created by JP on 24/05/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import Quickblox

class CommentModel: NSObject {
    var strComment = ""
    var strCommentId = ""
    var strTime = ""
    
    var strCurrentPage = ""
    var strTotalPage = ""
    
    var userDetails = UserModel()
}

class FeedImageModel: NSObject {
    var strFeedId = ""
    var strUrl = ""
    var strImageId = ""
    var isVideo = false
    var mediaData = Data()
}

class FeedModel: NSObject {
    
    var strComment = ""
    var strFeedId = ""
    var strLikeCount = ""
    var strCommentCount = ""
    var isLike = false
    var isVideo = false
    var strDateAndTime = ""
    var strCurrentPage = ""
    var strTotalPage = ""
    
    var userDetails = UserModel()
    var comments = [CommentModel]()
    var arrFeedImages = [FeedImageModel]()
    
    
    func getListOfFeedBy(strPage: String, success:@escaping ([FeedModel]) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIFeedList)
        let dictParam = ["page_no":strPage]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            success(self.createListOfFeeds(response: response!))
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    func addNewFeed(strComment:String, arrURLs: [FeedImageModel], success:@escaping (FeedModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIAddNewFeed)
        
        var arrImageUsers = [[String:String]]()
        
        for details in arrURLs {
            
            var dict = [String:String]()
            dict["url"] = details.strUrl
            dict["type"] = details.isVideo ? "Video" : "Image"
            arrImageUsers.append(dict)
        }
        
        let arrImages = "\(self.json(from: arrImageUsers) ?? "")"
        
        let dictParam = ["description":strComment,
                         "imageArr":arrImages] as [String : Any]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: true, apiURL: url!, dictParam: dictParam, success: { (response) in
                success(self)
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    func editFeed(strRemovedImages:String, strComment:String, arrURLs: [String], success:@escaping (FeedModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let arrImages = "\(self.json(from: arrURLs) ?? "")"
        
        let url = URL(string: appBaseURL + APIEditNewFeed)
        let dictParam = ["description":strComment,
                         "removeImages":"",
                         "feedID":self.strFeedId,
                         "imageArr":arrImages] as [String : Any]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: true, apiURL: url!, dictParam: dictParam, success: { (response) in
                success(self)
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    func likeFeed(success:@escaping (FeedModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APILikeFeed)
        let dictParam = ["feedID":self.strFeedId]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
                success(self)
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    func reportFeed(reason:String, description:String, success:@escaping (FeedModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIReportFeed)
        let dictParam = ["feedID":self.strFeedId,
                         "reason":reason,
                         "description":description]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: true, apiURL: url!, dictParam: dictParam, success: { (response) in
                success(self)
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    func commentFeed(strComment: String, success:@escaping (CommentModel) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APIAddComment)
        let dictParam = ["feedID":self.strFeedId,
                         "comment":strComment]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: true, apiURL: url!, dictParam: dictParam, success: { (response) in
                
            let json = JSON(response as Any)
            let dictResponse = json.dictionary
            let details = dictResponse!["data"]!.dictionary
            
            let commentDetails = CommentModel()
            commentDetails.strCurrentPage        = ""
            commentDetails.strTotalPage          = ""
            commentDetails.strTime               = details!["createdAt"]!.stringValue
            commentDetails.strComment            = details!["comment"]!.stringValue
            commentDetails.strCommentId          = details!["id"]!.stringValue
            
            let userDetails = details!["users"]!.dictionary
            commentDetails.userDetails.strId                 = userDetails!["id"]!.stringValue
            commentDetails.userDetails.strUserFirstName      = userDetails!["firstName"]!.stringValue
            commentDetails.userDetails.strUserLastName       = userDetails!["lastName"]!.stringValue
            commentDetails.userDetails.strUserDisplayName    = userDetails!["displayName"]!.stringValue
            commentDetails.userDetails.strProfileImage       = userDetails!["profileImage"]!.stringValue

            success(commentDetails)
            
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    
    func getListOfFeedComment(strPage: String, success:@escaping ([CommentModel]) -> Void, failed:@escaping (String?) -> Void) {
        
        let url = URL(string: appBaseURL + APICommentList)
        let dictParam = ["page_no":strPage,
                         "feedID":self.strFeedId]
        
        NetworkManager.BaseRequestSharedInstance.POSTRequset(isProgress: false, apiURL: url!, dictParam: dictParam, success: { (response) in
            success(self.createListOfComments(response: response!))
        }) { (errorMsg) in
            failed(errorMsg!)
        }
        
    }
    
    private func createListOfFeeds(response: [String: AnyObject]) -> [FeedModel] {
        
        var arrNewList = [FeedModel]()
        
        let json = JSON(response as Any)
        let dictResponse = json.dictionary
        let dictTemp = dictResponse!["data"]!.dictionary
        let arrList = dictTemp!["feedslist"]!.arrayValue
        
        for details in arrList {
            
            let model = FeedModel()
            
            model.strCurrentPage        = dictTemp!["current_page"]!.stringValue
            model.strTotalPage          = dictTemp!["total_page"]!.stringValue
            
            model.strFeedId             = details["id"].stringValue
            model.strComment            = details["description"].stringValue
            model.strLikeCount          = details["totalLikes"].stringValue
            model.strCommentCount       = details["totalComments"].stringValue
            model.strDateAndTime        = details["createdAt"].stringValue
            model.isLike                = details["isLiked"].boolValue
            
            model.isVideo               = details["type"].stringValue == "Image" ? false : true
            
            let arrDetails = details["feed_images"].arrayValue
            
            for details in arrDetails {
                
                let imageDetails = FeedImageModel()
                imageDetails.strFeedId = details["feedID"].stringValue
                imageDetails.strImageId = details["id"].stringValue
                imageDetails.strUrl = details["image"].stringValue
                
                if(details["type"].stringValue == "Image") {
                    imageDetails.isVideo = false
                }
                else {
                    imageDetails.isVideo = true
                }
                
                model.arrFeedImages.append(imageDetails)
            }
                        
            let userDetails = details["users"].dictionary
            model.userDetails.strId                 = userDetails!["id"]!.stringValue
            model.userDetails.strUserFirstName      = userDetails!["firstName"]!.stringValue
            model.userDetails.strUserLastName       = userDetails!["lastName"]!.stringValue
            model.userDetails.strUserDisplayName    = userDetails!["displayName"]!.stringValue
            model.userDetails.strProfileImage       = userDetails!["profileImage"]!.stringValue
            
            arrNewList.append(model)
            
        }
        
        return arrNewList
        
    }
    
    private func createListOfComments(response: [String: AnyObject]) -> [CommentModel] {
        
        var arrNewList = [CommentModel]()
        
        let json = JSON(response as Any)
        let dictResponse = json.dictionary
        let dictTemp = dictResponse!["data"]!.dictionary
        let arrList = dictTemp!["commentslist"]!.arrayValue
        
        for details in arrList {
            
            let model = CommentModel()
            
            model.strCurrentPage        = dictTemp!["current_page"]!.stringValue
            model.strTotalPage          = dictTemp!["total_page"]!.stringValue
            
            model.strTime               = details["createdAt"].stringValue
            model.strComment            = details["comment"].stringValue
            model.strCommentId          = details["id"].stringValue
            
            let userDetails = details["users"].dictionary
            model.userDetails.strId                 = userDetails!["id"]!.stringValue
            model.userDetails.strUserFirstName      = userDetails!["firstName"]!.stringValue
            model.userDetails.strUserLastName       = userDetails!["lastName"]!.stringValue
            model.userDetails.strUserDisplayName    = userDetails!["displayName"]!.stringValue
            model.userDetails.strProfileImage       = userDetails!["profileImage"]!.stringValue
            
            arrNewList.append(model)
            
        }
        
        return arrNewList
        
    }
    
    func getDisplayName() -> String {
        
        if(self.userDetails.strUserDisplayName != "") {
           return self.userDetails.strUserDisplayName
        }
        else {
            return self.userDetails.strUserFirstName + " " + self.userDetails.strUserLastName
        }
    }

    func json(from object:Any) -> String? {
        
        var myJsonString = ""
        
        do {
            let data =  try JSONSerialization.data(withJSONObject:object, options: .prettyPrinted)
            myJsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        } catch {
            print(error.localizedDescription)
        }
        
        return myJsonString
        
    }
    
}
