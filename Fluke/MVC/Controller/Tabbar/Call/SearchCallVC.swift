//
//  SearchCallVC.swift
//  Fluke
//
//  Created by JP on 28/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class SearchCallVC: UIViewController {

    @IBOutlet private weak var ivImage: UIImageView!
    @IBOutlet private weak var lblText: UILabel!
    @IBOutlet private weak var cntWidth: NSLayoutConstraint!
    
    private var maximumWidth: CGFloat!
    private var minimumWidth: CGFloat!
    
    private var userDetails = NearByModel()
    
    var strCountry: String!
    var strGender: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.getRandomUser()
        }
        
    }
    
    private func setUpUI() {
        minimumWidth = -(((self.view.frame.size.width - 48)/3) - 48)
        maximumWidth = 48
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.animation(cntValue: self.minimumWidth)
        }
        
    }
    
    private func animation(cntValue: CGFloat) {
        
        self.cntWidth.constant = cntValue
        
        UIView.animate(withDuration: 2.0, animations: {
            self.view.layoutIfNeeded()
        }) { (result) in
            
            if(cntValue != self.minimumWidth) {
                self.animation(cntValue: self.minimumWidth)
            }
            else {
                self.animation(cntValue: self.maximumWidth)
            }
        }
    }
    
    private func getRandomUser() {
        userDetails.getRandomUser(gender:strGender, country: strCountry, success: { (user) in
            
            DispatchQueue.main.async {
                let startCallingVC = self.storyboard?.instantiateViewController(withIdentifier: "StartCallingVC") as! StartCallingVC
                startCallingVC.userDetails = self.userDetails
                self.navigationController?.pushViewController(startCallingVC, animated: false)
            }
            
        }) { (strError) in
            self.showAlertWithBackController(strMsg: strError!)
        }
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
}
