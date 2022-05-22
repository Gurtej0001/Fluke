//
//  OTPVC.swift
//  Fluke
//
//  Created by JP on 24/02/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class OTPVC: UIViewController {

    @IBOutlet weak private var txtOTP: UITextField!
    
    @IBOutlet weak private var lblOne: UILabel!
    @IBOutlet weak private var lblTwo: UILabel!
    @IBOutlet weak private var lblThree: UILabel!
    @IBOutlet weak private var lblFour: UILabel!
    
    @IBOutlet weak private var viewOne: UIView!
    @IBOutlet weak private var viewTwo: UIView!
    @IBOutlet weak private var viewThree: UIView!
    @IBOutlet weak private var viewFour: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func btnBackClicked(_ btnSender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnSubmitClicked(_ btnSender: UIButton) {
        self.view.endEditing(true)
    }
    
    @IBAction private func btnResendClicked(_ btnSender: UIButton) {
        self.view.endEditing(true)
    }
}
