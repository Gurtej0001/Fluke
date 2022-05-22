//
//  SelfiVC.swift
//  Fluke
//
//  Created by JP on 06/06/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

class SelfiVerifyVC: UIViewController {
    
    @IBOutlet private var btnSelfi: UIButton!
    @IBOutlet private var lblNotVerify: UILabel!
    @IBOutlet private var btnVerify: UIButton!
    
    var selfiImageData:Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
 
    private func setupUI() {
        btnSelfi.layer.cornerRadius = 8.0
        self.lblNotVerify.text = "(\(UserModel.sharedUser.strPhotoIDVerifiedStatus))"
        
        if(UserModel.sharedUser.strPhotoIDVerifiedStatus == "Verified") {
            self.btnVerify.isHidden = true
        }
        
        if(UserModel.sharedUser.strPhotoPhotoURL != "") {
            self.btnSelfi.sd_setBackgroundImage(with: URL(string: UserModel.sharedUser.strPhotoPhotoURL), for: .normal, placeholderImage: #imageLiteral(resourceName: "selfie_Placeholder"), options: .lowPriority, context: nil)
        }
        
    }
 
    private func setViewBorder(_ view: UIView) {
        view.layer.cornerRadius = 8.0
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        view.layer.borderWidth = 0.5
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnEditPhotoClicked(_btnSender: UIButton) {
        self.view.endEditing(true)
        
        let picker = ImagePickerManager()
        
        picker.pickImage(self, type: .photo) { (imageData, isVideo) in
            self.selfiImageData = imageData
            self.btnSelfi.setBackgroundImage(UIImage(data: self.selfiImageData), for: .normal)
        }
    }
    
    @IBAction private func btnSend(_btnSender: UIButton) {
        
        if(self.selfiImageData == nil) {
            self.showAlert(strMsg: "Upload selfie with proof")
        }
        else {
            
            SVProgressHUD.show(withStatus: "Uploading...")
            
            S3Manager.sharedS3Manager.uploadFile(with: self.selfiImageData, type: "image/jpeg", folderName: "proof/", success: { (strURL) in
                self.callAPIwith(strEmail: nil, strImageURL: strURL)
            }) { (strError) in
                self.showAlert(strMsg: strError!)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func callAPIwith(strEmail: String?, strImageURL: String?) {
        UserModel.sharedUser.verifyUser(strEmail: strEmail, strImageURL: strImageURL, success: { (msg) in
            UserModel.sharedUser.strPhotoPhotoURL = strImageURL ?? ""
            self.showAlertWithBackController(strMsg: "Selfie uploaded successfully")
            SVProgressHUD.dismiss()
        }) { (strError) in
            self.showAlert(strMsg: strError!)
            SVProgressHUD.dismiss()
        }
    }
    
}
