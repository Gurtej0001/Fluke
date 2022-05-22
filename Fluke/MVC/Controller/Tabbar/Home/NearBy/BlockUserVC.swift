//
//  BlockUser.swift
//  Fluke
//
//  Created by JP on 10/08/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class BlockUserVC: UIViewController {

    @IBOutlet weak private var viewMsg: UIView!
    @IBOutlet weak private var tvMsg: UITextView!
    
    @IBOutlet weak private var ivImage: UIImageView!
    @IBOutlet weak private var lblName: UILabel!
    @IBOutlet weak private var lblEmail: UILabel!
    
    var userProfile: UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setAboutTextView()
        self.setValues()
    }
    
    private func setAboutTextView() {
        
        self.ivImage.layer.cornerRadius = self.ivImage.frame.size.width/2
        
        tvMsg.layer.cornerRadius = 8.0
        tvMsg.layer.borderColor = tvMsg.tintColor.withAlphaComponent(0.4).cgColor
        tvMsg.layer.borderWidth = 0.5
    }
    
    private func setValues() {
        self.lblName.text = userProfile.getDisplayName()
        //self.lblEmail.text = userProfile.strEmailId
        self.lblEmail.text = ""
        setImagefromURL(ivImage: self.ivImage, strUrl: userProfile.strProfileImage)
    }
    
    @IBAction private func btnBlockUser(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnBlock(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if(self.tvMsg.text.isEmpty) {
            self.showAlert(strMsg: Constant.EmptyMsg())
        }
        else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: appName, message: "Are you sure you want to block \(self.lblName.text ?? "")?", preferredStyle: .alert)
            
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                        self.userProfile.blockUser(strMsg: self.tvMsg.text!, strUserId: self.userProfile.strId, success: { (msg) in
                            self.showAlertWithBackController(strMsg: "Thank you, we received your report and we will act accordingly")
                        }) { (strError) in
                            self.showAlert(strMsg: strError!)
                        }
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
