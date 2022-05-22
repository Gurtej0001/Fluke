//
//  CommunityVC.swift
//  Fluke
//
//  Created by JP on 15/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class CommunityVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isHidden = true
        
        if(UserModel.sharedUser.strIsCommunityUser == "Yes") {
            self.hideViewWithAnimation()
        }
        else {
            self.view.isHidden = false
        }
    }
    
    @IBAction private func btnConfirmationPressed(btnSender: UIButton) {
        let communityCoinfirmationVC = storyboard?.instantiateViewController(withIdentifier: "CommunityCoinfirmationVC") as! CommunityCoinfirmationVC
        view.addSubview(communityCoinfirmationVC.view)
        addChild(communityCoinfirmationVC)
    }
    
    private func hideViewWithAnimation() {
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.01, animations: {
                
            }, completion: {
                (value: Bool) in
                
                let feedListVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedListVC") as! FeedListVC
                self.navigationController?.setViewControllers([feedListVC], animated: false)
            })
            
        }
    }
}
