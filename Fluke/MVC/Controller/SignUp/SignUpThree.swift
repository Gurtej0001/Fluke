//
//  SignUpThree.swift
//  Fluke
//
//  Created by JP on 25/02/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignUpThree: UIViewController {
    
    @IBOutlet weak private var btnUpload: UIButton!
    @IBOutlet weak private var ivImage: UIImageView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.ivImage.layer.cornerRadius = self.ivImage.frame.size.width/2
        }
        
        self.setUploadButton(btnUpload)
    }
    
    private func setUploadButton(_ btnUpload: UIButton) {
        btnUpload.layer.cornerRadius = 8.0
        btnUpload.layer.borderColor = btnUpload.tintColor.withAlphaComponent(0.4).cgColor
        btnUpload.layer.borderWidth = 0.5
    }
    
    @IBAction private func btnBackClicked(_ btnSender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnImageClicked(_ btnSender: UIButton) {
        
        let picker = ImagePickerManager()
        
        picker.pickImage(self, type: .photo) { (imageData, isVideo) in
            
            self.ivImage.image = UIImage(data: imageData)
            
            SVProgressHUD.show(withStatus: "Uploading...")
            
            S3Manager.sharedS3Manager.uploadFile(with: imageData, type: "image/jpeg", folderName: "profilePhoto/", success: { (strURL) in
                SVProgressHUD.dismiss()
                UserModel.sharedUser.strProfileImage = strURL
            }) { (strError) in
                SVProgressHUD.dismiss()
            }
        }
        
    }
    
    @IBAction private func btnSubmitClicked(_ btnSender: UIButton) {
        
        self.view.endEditing(true)
        
        UserModel.sharedUser.registerNewUser(success: { (response) in
            
            DispatchQueue.main.async {
                let congratulationVC = self.storyboard?.instantiateViewController(withIdentifier: "CongratulationVC") as! CongratulationVC
                self.navigationController?.pushViewController(congratulationVC, animated: true)
            }
            
        }) { (strError) in
            self.showAlert(strMsg: strError!)
        }
    }
}
