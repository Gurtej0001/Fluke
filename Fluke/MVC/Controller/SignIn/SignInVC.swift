//
//  SignInVC.swift
//  Fluke
//
//  Created by JP on 24/02/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    
    @IBOutlet weak private var txtEmail: UITextField!
    @IBOutlet weak private var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func btnBackClicked(_ btnSender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnLoginClicked(_ btnSender: UIButton) {
        self.view.endEditing(true)
        
        if(IsEmpty(strText: txtEmail.text)) {
            self.showAlert(strMsg: Constant.EmptyEmail())
        }
        else if(!isValidEmail(txtEmail.text)){
            self.showAlert(strMsg: Constant.InValidEmail())
        }
        else if(IsEmpty(strText: txtPassword.text)) {
            self.showAlert(strMsg: Constant.EmptyPassword())
        }
        else {
                
            //if(txtEmail.text == "ketaniphone1@gmail.com") {
                //self.showAlert(strMsg: UserModel.sharedUser.strFCMToken)
            //}
            
            UserModel.sharedUser.strEmailId = txtEmail.text!
            UserModel.sharedUser.strPassword = txtPassword.text!
            
            UserModel.sharedUser.loginUser(success: { (response) in
                
                DispatchQueue.main.async {
                    let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabbarVC") as! TabbarVC
                    tabbarVC.selectedIndex = 2
                    self.navigationController?.pushViewController(tabbarVC, animated: true)
                }
                
            }) { (strError) in
                
            }
            
        }
    }
    
    @IBAction private func btnCreateNowClicked(_ btnSender: UIButton) {
        let signUpOne = storyboard?.instantiateViewController(withIdentifier: "SignUpOne") as! SignUpOne
        self.navigationController?.pushViewController(signUpOne, animated: true)
        self.view.endEditing(true)
    }
    
    @IBAction private func btnForgotClicked(_ btnSender: UIButton) {
        let forgotPassVC = storyboard?.instantiateViewController(withIdentifier: "ForgotPassVC") as! ForgotPassVC
        self.navigationController?.pushViewController(forgotPassVC, animated: true)
        self.view.endEditing(true)
    }
    
}
