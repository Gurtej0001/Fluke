//
//  ContactMsgVC.swift
//  Fluke
//
//  Created by JP on 15/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class ContactMsgVC: UIViewController {
    
    @IBOutlet weak var viewMsg: UIView!
    @IBOutlet weak var txtDes: UITextView!
    @IBOutlet weak var txtSubject: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
 
    private func setupUI() {
        viewMsg.layer.cornerRadius = 8
        viewMsg.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        viewMsg.layer.borderWidth = 0.5
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnSend(_btnSender: UIButton) {
        
        if(txtSubject.text == "") {
            showAlert(strMsg: "Enter subject")
        }
        else if(txtDes.text == "") {
            showAlert(strMsg: "Enter description")
        }
        else {
            
            UserModel.sharedUser.contactUsMsg(strSubject: txtSubject.text!, strDesc: txtDes.text!, success: { (response) in
                self.showAlertWithBackController(strMsg: "Message submited successfully")
            }) { (strError) in
                self.showAlert(strMsg: strError!)
            }
            
        }
        
    }
    
}
