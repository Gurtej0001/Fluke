//
//  ContactUsVC.swift
//  Fluke
//
//  Created by JP on 15/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class ContactUsVC: UIViewController {

    @IBOutlet weak var btnMessage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    private func setupUI() {
        btnMessage.layer.cornerRadius = 4
        btnMessage.layer.borderColor = #colorLiteral(red: 0.937254902, green: 0.2431372549, blue: 0.568627451, alpha: 1)
        btnMessage.layer.borderWidth = 0.5
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnCall(_btnSender: UIButton) {

    }
    
    @IBAction private func btnEmail(_btnSender: UIButton) {
        
    }
    
    @IBAction private func btnMessage(_btnSender: UIButton) {
        let contactMsgVC = storyboard?.instantiateViewController(withIdentifier: "ContactMsgVC") as! ContactMsgVC
        self.navigationController?.pushViewController(contactMsgVC, animated: true)
    }
}
