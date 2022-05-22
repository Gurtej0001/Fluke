//
//  StartCallingVC.swift
//  Fluke
//
//  Created by JP on 12/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import Quickblox

class StartCallingVC: CallExtention {

    @IBOutlet private weak var ivImage: UIImageView!
    @IBOutlet private weak var imageBgView: UIView!
    @IBOutlet private weak var lblName: UILabel!
    @IBOutlet private weak var lblBirthDate: UILabel!
    @IBOutlet private weak var lblAbout: UILabel!
    @IBOutlet private weak var ivIsVerify: UIImageView!
    
    var userDetails: NearByModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        ivImage.layer.cornerRadius = ivImage.frame.size.width/2
        imageBgView.layer.cornerRadius = imageBgView.frame.size.width/2
        
        setImagefromURL(ivImage: ivImage, strUrl: userDetails.strProfileImage)
        
        DispatchQueue.main.async {
            self.lblName.text = self.userDetails.getDisplayName()
            self.lblBirthDate.text = self.userDetails.strUserAge
            self.lblAbout.text = self.userDetails.strAboutMe
            
            self.ivIsVerify.isHidden = !self.userDetails.isVerify
        }
    }
    
    @IBAction private func btnBack(_btnSender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnCall(_btnSender: UIButton) {

        //if(UserModel.sharedUser.strPlanId == "1") {
            QBManager.sharedManager.createChatDialog(strUserId: userDetails.strId, success: { (chatDialog) in
                self.setCallwithUser(with: .video, chatDialog: (chatDialog[Constant.ChatDialogDetails.ChatDialog()] as? QBChatDialog)!, otherUserId: self.userDetails.strId)
            }) { (strError) in
                
            }
//        }
//        else {
//            DispatchQueue.main.async {
//                self.showAlert(strMsg: "You have to subscribe call feature")
//            }
//        }
    }
    
}
