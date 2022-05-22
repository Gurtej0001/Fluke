//
//  GenderSelectionVC.swift
//  Fluke
//
//  Created by JP on 18/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

protocol GenderSelectionDelegate: class {
    func selectedGender(_ strGender: String?)
}

class GenderSelectionVC: UIViewController {
    
    @IBOutlet private weak var viewPopupUI:UIView!
    @IBOutlet private weak var viewMain:UIView!
    @IBOutlet private weak var btnCancel:UIButton!
    @IBOutlet private weak var btnSelect:UIButton!
    
    @IBOutlet private weak var btnMale:UIButton!
    @IBOutlet private weak var btnFeMale:UIButton!
    @IBOutlet private weak var btnOther:UIButton!
    
    var selectedGender: String!
    var isHideOther: Bool!
    weak var delegate: GenderSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.showViewWithAnimation()
        
        btnOther.isHidden = isHideOther
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction private func btnSelectPressed(_ btnSender: UIButton) {
        self.hideViewWithAnimation()
    }
    
    @IBAction private func btnCancelPressed(_ btnSender: UIButton) {
        self.hideViewWithAnimation()
    }
    
    private func setupUI() {
        btnCancel.layer.cornerRadius = 8
        btnCancel.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        btnCancel.layer.borderWidth = 1.0
        
        viewPopupUI.layer.cornerRadius = 8.0
        
        if(selectedGender == Constant.Gender.MALE()) {
            self.btnGenderClicked(btnMale)
        }
        else if(selectedGender == Constant.Gender.FEMALE()) {
            self.btnGenderClicked(btnFeMale)
        }
        else if(selectedGender == Constant.Gender.OTHER()) {
            self.btnGenderClicked(btnOther)
        }
    }
    
    @IBAction private func btnGenderClicked(_ btnGender: UIButton) {
        
        btnMale.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        btnFeMale.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        btnOther.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        self.setGenderButton(btnMale)
        self.setGenderButton(btnFeMale)
        self.setGenderButton(btnOther)
        
        btnGender.tintColor = #colorLiteral(red: 0.9597017169, green: 0.3549151421, blue: 0.6354215741, alpha: 1)
        self.setGenderButton(btnGender)
        
        if(btnGender == btnMale) {
            selectedGender = Constant.Gender.MALE()
        }
        else if(btnGender == btnFeMale) {
            selectedGender = Constant.Gender.FEMALE()
        }
        else {
            selectedGender = Constant.Gender.OTHER()
        }
        
    }
    
    private func setGenderButton(_ btnGender: UIButton) {
        btnGender.layer.cornerRadius = 8.0
        btnGender.layer.borderColor = btnGender.tintColor.withAlphaComponent(0.4).cgColor
        btnGender.layer.borderWidth = 0.5
    }
    
    //MARK: - Animation Method
    
    private func showViewWithAnimation() {
        
        self.view.alpha = 0
        self.viewPopupUI.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.3) {
            self.viewPopupUI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1
        }
        
    }
    
    private func hideViewWithAnimation() {
        
        delegate?.selectedGender(selectedGender)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.viewPopupUI.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.view.alpha = 0
            
        }, completion: {
            (value: Bool) in
            self.removeFromParent()
            self.view.removeFromSuperview()
        })
    }
    
}
