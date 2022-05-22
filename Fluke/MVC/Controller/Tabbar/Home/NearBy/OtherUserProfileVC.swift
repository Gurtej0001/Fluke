//
//  OtherUserProfileVC.swift
//  Fluke
//
//  Created by JP on 17/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

class OtherUserProfileVC: UIViewController {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblDob: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    
    @IBOutlet weak var ivProfileImage: UIImageView!
    @IBOutlet weak var btnChat: UIButton!
    
    var userId: String!
    
    private var userProfile: UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getUserDetails()
    }
    
    private func setupUI() {
        self.ivProfileImage.layer.cornerRadius = self.ivProfileImage.frame.size.width/2
        self.btnChat.layer.cornerRadius = 4
        self.btnChat.isHidden = true
        
//        if(UserModel.sharedUser.strPlanId == "0") {
//            self.btnChat.isHidden = true
//        }
//        else {
            self.btnChat.isHidden = false
//        }
    }
    
    private func getUserDetails() {
        
        UserModel.sharedUser.getUserDetailsFor(strId: userId, success: { (otherUserDetails) in
            
            self.userProfile = otherUserDetails
            
            DispatchQueue.main.async {
                self.lblName.text = otherUserDetails.getDisplayName()
                self.lblEmail.text = otherUserDetails.strEmailId
                self.lblAbout.text = otherUserDetails.strAboutMe
                self.lblGender.text = otherUserDetails.strGender
                self.lblDob.text = otherUserDetails.strAgeorDOB
                self.lblCountry.text = otherUserDetails.strUserCountry
                self.lblCity.text = otherUserDetails.strUserCity
                setImagefromURL(ivImage: self.ivProfileImage, strUrl: otherUserDetails.strProfileImage)
                
            }
            
        }) { (strError) in
            self.showAlertWithBackController(strMsg: strError!)
        }
        
    }
    
    @IBAction private func btnBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnBlockUser(_ sender: UIBarButtonItem) {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let blockUserVC = story.instantiateViewController(withIdentifier: "BlockUserVC") as! BlockUserVC
        blockUserVC.userProfile = self.userProfile
        self.navigationController?.pushViewController(blockUserVC, animated: true)
    }
    
    @IBAction private func openProfilePhoto (_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fullPhotosVC = storyboard.instantiateViewController(withIdentifier: "FullPhotosVC") as! FullPhotosVC
        
        let temp = FeedImageModel()
        temp.strFeedId = ""
        
        temp.strUrl = ""
        
        if (self.userProfile.strProfileImage != nil) {
            temp.strUrl = self.userProfile.strProfileImage
        }
        
        
        temp.strImageId = ""
        temp.isVideo = false
        temp.mediaData = Data()
        
        fullPhotosVC.imageObjs = [temp]
        let nav = UINavigationController.init(rootViewController: fullPhotosVC)
        nav.navigationBar.isHidden = true
        self.navigationController!.present(nav, animated: true, completion: nil)
    }
    
    @IBAction private func btnChat(_ sender: UIButton) {
        self.view.endEditing(true)
        
        SVProgressHUD.show(withStatus: "Fetch details...")
        
        QBManager.sharedManager.createChatDialog(strUserId: userId, success: { (dialog) in
            
            SVProgressHUD.dismiss()
            
            let story = UIStoryboard.init(name: "Chat", bundle: nil)
            let chatViewController = story.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            
            let di = dialog[Constant.ChatDialogDetails.ChatDialog()] as? QBChatDialog
            chatViewController.otherUserName = self.lblName.text
            chatViewController.dialogID = di?.id
            chatViewController.chatdialog = di
            self.navigationController?.pushViewController(chatViewController, animated: true)
            
            
        }) { (strError) in
            
        }
        
    }
}
