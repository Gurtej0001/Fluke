//
//  SignUpOne.swift
//  Fluke
//
//  Created by JP on 24/02/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class SignUpOne: UIViewController {
    
    @IBOutlet weak private var txtFirstName: UITextField!
    @IBOutlet weak private var txtLastName: UITextField!
    @IBOutlet weak private var txtUserName: UITextField!
    @IBOutlet weak private var txtEmail: UITextField!
    @IBOutlet weak private var txtPassword: UITextField!
    @IBOutlet weak private var txtConfirmPassword: UITextField!
    
    @IBOutlet weak private var btnPrivacy: UIButton!
    @IBOutlet weak private var btnTerms: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPrivacy.layer.cornerRadius = 4
        btnPrivacy.layer.borderColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        btnPrivacy.layer.borderWidth = 2
        btnPrivacy.layer.masksToBounds = true
        
        btnTerms.layer.cornerRadius = 4
        btnTerms.layer.borderColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        btnTerms.layer.borderWidth = 2
        btnTerms.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction private func btnBackClicked(_ btnSender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnPrivacyClicked(_ btnSender: UIButton) {
        
        self.view.endEditing(true)
        
        if(btnSender.tag == 20) {
            let staticVC = storyboard?.instantiateViewController(withIdentifier: "StaticVC") as! StaticVC
            staticVC.strTitle = "Privacy Policy"
            staticVC.strSlug = "privacypolicy"
            self.navigationController?.pushViewController(staticVC, animated: true)
        }
        else if(btnPrivacy.tag == 0) {//Select
            btnPrivacy.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
            btnPrivacy.tag = 1
        }
        else {
            btnPrivacy.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            btnPrivacy.tag = 0
        }
        
    }
    
    @IBAction private func btnTermsClicked(_ btnSender: UIButton) {
        
        self.view.endEditing(true)
        
        if(btnSender.tag == 20) {
            let staticVC = storyboard?.instantiateViewController(withIdentifier: "StaticVC") as! StaticVC
            staticVC.strTitle = "Terms & Conditions"
            staticVC.strSlug = "terms&conditions"
            self.navigationController?.pushViewController(staticVC, animated: true)
        }
        else if(btnTerms.tag == 0) {//Select
            btnTerms.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
            btnTerms.tag = 1
        }
        else {
            btnTerms.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            btnTerms.tag = 0
        }
        
    }
    
    @IBAction private func btnInfoClicked(_ btnSender: UIButton) {
        self.view.endEditing(true)
        self.showAlert(strMsg: "All users will able to see your display name.")
    }
    
    @IBAction private func btnSubmitClicked(_ btnSender: UIButton) {
        
        self.view.endEditing(true)
        
        if(IsEmpty(strText: txtFirstName.text)) {
            self.showAlert(strMsg: Constant.EmptyFirstName())
        }
        else if(IsEmpty(strText: txtLastName.text)) {
            self.showAlert(strMsg: Constant.EmptyLastName())
        }
        else if(IsEmpty(strText: txtEmail.text)) {
            self.showAlert(strMsg: Constant.EmptyEmail())
        }
        else if(!isValidEmail(txtEmail.text)){
            self.showAlert(strMsg: Constant.InValidEmail())
        }
        else if(IsEmpty(strText: txtPassword.text)) {
            self.showAlert(strMsg: Constant.EmptyPassword())
        }
        else if(IsEmpty(strText: txtConfirmPassword.text)) {
            self.showAlert(strMsg: Constant.EmptyConfirmPassword())
        }
        else if(txtPassword.text != txtConfirmPassword.text) {
            self.showAlert(strMsg: Constant.NotMatch())
        }
        else if(btnTerms.tag == 0) {
            self.showAlert(strMsg: Constant.SelectTerms())
        }
        else if(btnPrivacy.tag == 0) {
            self.showAlert(strMsg: Constant.SelectPrivacy())
        }
        else {
            
            UserModel.sharedUser.strUserFirstName = txtFirstName.text!
            UserModel.sharedUser.strUserLastName = txtLastName.text!
            UserModel.sharedUser.strUserDisplayName = txtUserName.text!
            UserModel.sharedUser.strEmailId = txtEmail.text!
            UserModel.sharedUser.strPassword = txtPassword.text!
            
            let signUpTwo = storyboard?.instantiateViewController(withIdentifier: "SignUpTwo") as! SignUpTwo
            self.navigationController?.pushViewController(signUpTwo, animated: true)
            self.view.endEditing(true)
            
        }
    }
    
    @IBAction private func btnLoginClicked(_ btnSender: UIButton) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
}

