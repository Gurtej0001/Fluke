//
//  ChangePassVC.swift
//  Fluke
//
//  Created by JP on 05/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class ChangePassVC: UIViewController {
    
    @IBOutlet weak private var txtPassword: UITextField!
    @IBOutlet weak private var txtNewPassword: UITextField!
    @IBOutlet weak private var txtConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtPassword.becomeFirstResponder()
    }
    
    @IBAction private func btnChangePassClicked(_btnSender: UIButton) {
        self.view.endEditing(true)
        
        if(IsEmpty(strText: txtPassword.text)) {
            self.showAlert(strMsg: Constant.EmptyOldPass())
        }
        else if(IsEmpty(strText: txtNewPassword.text)){
            self.showAlert(strMsg: Constant.EmptyNewPass())
        }
        else if(IsEmpty(strText: txtConfirmPassword.text)) {
            self.showAlert(strMsg: Constant.EmptyConfirmPassword())
        }
        else if(txtNewPassword.text != txtConfirmPassword.text) {
            self.showAlert(strMsg: Constant.NotMatchOldPass())
        }
        else {
            
            UserModel.sharedUser.changeUserPassword(strOld: txtPassword.text!, strNew: txtNewPassword.text!, success: { (response) in
                
                self.showAlertWithBackController(strMsg: "Password change sucessfully.")
                
            }) { (strError) in
                self.showAlert(strMsg: strError!)
            }
            
        }
        
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}
