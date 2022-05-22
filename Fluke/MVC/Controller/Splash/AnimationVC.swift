//
//  AnimationVC.swift
//  Fluke
//
//  Created by JP on 05/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class AnimationVC: UIViewController {

    @IBOutlet private weak var ivAnimation: UIImageView!
    @IBOutlet private weak var cntWidth: NSLayoutConstraint!
    
    @IBOutlet private weak var btnSignUp: UIButton!
    @IBOutlet private weak var btnSignIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.animation()
        }
        
    }
    
    private func animation() {
        
        self.cntWidth.constant = self.view.frame.size.width
        
        UIView.animate(withDuration: 2.0, animations: {
            self.view.layoutIfNeeded()
        }) { (result) in
            
            UIView.animate(withDuration: 1.0, animations: {
                self.ivAnimation.transform = CGAffineTransform(scaleX: -1, y: 1)
            }) { (result) in
                
                if(UserModel.sharedUser.strId == "") {//Not login
                    
                    self.btnSignIn.isHidden = false
                    self.btnSignUp.isHidden = false
                }
                else {
                    let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabbarVC") as! TabbarVC
                    tabbarVC.selectedIndex = 2
                    self.navigationController?.pushViewController(tabbarVC, animated: true)
                }
                
            }
            
        }
        
    }
    
    @IBAction func btnSignIn(btn: UIButton) {
        let signUpOne = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.navigationController?.pushViewController(signUpOne, animated: true)
    }
    
    @IBAction func btnSignUp(btn: UIButton) {
        let signUpOne = self.storyboard?.instantiateViewController(withIdentifier: "SignUpOne") as! SignUpOne
        self.navigationController?.pushViewController(signUpOne, animated: true)
    }
    
}
