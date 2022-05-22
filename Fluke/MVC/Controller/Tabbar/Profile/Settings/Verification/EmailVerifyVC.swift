//
//  VerifyProfileVC.swift
//  Fluke
//
//  Created by JP on 06/06/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class EmailVerifyVC: UIViewController {

    @IBOutlet private var viewEmail: UIView!
    @IBOutlet private var txtEmail: UITextField!
    @IBOutlet private var lblNotVerify: UILabel!
    @IBOutlet private var btnVerify: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
 
    private func setupUI() {
        self.setViewBorder(viewEmail)
        self.txtEmail.text = UserModel.sharedUser.strEmailId
        self.lblNotVerify.text = "(\(UserModel.sharedUser.strEmailVerifiedStatus))"
        
        if(UserModel.sharedUser.strEmailVerifiedStatus == "Verified") {
            self.btnVerify.isHidden = true
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
        
    @IBAction private func btnSend(_btnSender: UIButton) {

        if(IsEmpty(strText: self.txtEmail.text)) {
            self.showAlert(strMsg: "Enter email address")
        }
        else {
            if(isValidEmail(txtEmail.text)) {
                self.callAPIwith(strEmail: txtEmail.text!, strImageURL: nil)
            }
            else {
                self.showAlert(strMsg: "Enter valid email address")
            }
        }
    }
    
    private func callAPIwith(strEmail: String?, strImageURL: String?) {
        UserModel.sharedUser.verifyUser(strEmail: strEmail, strImageURL: strImageURL, success: { (msg) in
            self.showAlertWithBackController(strMsg: "Verification mail sent to your inbox")
        }) { (strError) in
            self.showAlert(strMsg: strError!)
        }
    }
    
}
