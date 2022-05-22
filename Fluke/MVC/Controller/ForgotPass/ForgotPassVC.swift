//
//  ForgotPassVC.swift
//  Fluke
//
//  Created by JP on 24/02/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class ForgotPassVC: UIViewController {

    @IBOutlet weak private var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func btnBackClicked(_ btnSender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnSubmitClicked(_ btnSender: UIButton) {
        
        if(IsEmpty(strText: txtEmail.text)) {
            self.showAlert(strMsg: Constant.EmptyEmail())
        }
        else if(!isValidEmail(txtEmail.text)){
            self.showAlert(strMsg: Constant.InValidEmail())
        }
        else {
            UserModel.sharedUser.forgotPass(strEmail: txtEmail.text!, success: { (result) in
                self.showAlertWithBackController(strMsg: "Forgot password instruction mail sent to your mail id please check it.")
            }) { (strError) in
                self.showAlertWithBackController(strMsg: strError!)
            }
        }
    }
    
    @IBAction private func btnCreateNowClicked(_ btnSender: UIButton) {
        let signUpOne = storyboard?.instantiateViewController(withIdentifier: "SignUpOne") as! SignUpOne
        self.navigationController?.pushViewController(signUpOne, animated: true)
        self.view.endEditing(true)
    }
    
}
