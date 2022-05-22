//
//  MyProfileVC.swift
//  Fluke
//
//  Created by JP on 11/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import SDWebImage

class MyProfileVC: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    
    @IBOutlet weak var ivProfileImage: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setAllValues()
    }
    
    private func setupUI() {
        
        self.ivProfileImage.layer.cornerRadius = self.ivProfileImage.frame.size.width/2
        self.btnEdit.layer.cornerRadius = 4
    }
    
    private func setAllValues() {
        self.lblName.text = UserModel.sharedUser.getDisplayName()
        self.lblEmail.text = UserModel.sharedUser.strEmailId
        self.lblAbout.text = UserModel.sharedUser.strAboutMe
        self.lblGender.text = UserModel.sharedUser.strGender
        self.lblDOB.text = UserModel.sharedUser.strAgeorDOB
        self.lblCountry.text = UserModel.sharedUser.strUserCountry
        self.lblCity.text = UserModel.sharedUser.strUserCity

        setImagefromURL(ivImage: ivProfileImage, strUrl: UserModel.sharedUser.strProfileImage)
    }
    
    @IBAction private func btnSettings(_ sender: UIBarButtonItem) {
        let settingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction private func btnNotification(_ sender: UIBarButtonItem) {

    }
    
    @IBAction private func btnEdit(_ sender: UIButton) {
        
        let editProfileVC = storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(editProfileVC, animated: true)
        self.view.endEditing(true)
        
    }
}
