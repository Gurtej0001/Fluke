//
//  HomeCallVC.swift
//  Fluke
//
//  Created by JP on 18/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import Quickblox

class HomeCallVC: CallExtention {

    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var btnGenderIcon: UIButton!
    @IBOutlet weak var btnCountryIcon: UIButton!
    
    private var arrCountryList = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configQB()
        self.setUserStatus()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            QBManager.sharedManager.signUp(fullName: UserModel.sharedUser.getDisplayName(), login: UserModel.sharedUser.strId)
        }
    }
    
    private func setUserStatus() {
        
        UserModel.sharedUser.userOnlineOffline(strStatus: "True", success: { (response) in
        }) { (strError) in
        }
        
        UserModel.sharedUser.allCOuntryListForRandomSearch(success: { (arr) in
            
            DispatchQueue.main.async {
                self.arrCountryList = arr
                
                if(arr.count > 0) {
                    self.lblCountry.text = arr[0]
                }
            }
            
        }) { (strError) in
        }
        
    }
    
    @IBAction private func btnGenderClicked(_ btnSender: UIButton) {
        
        let genderSelectionVC = storyboard?.instantiateViewController(withIdentifier: "GenderSelectionVC") as! GenderSelectionVC
        genderSelectionVC.delegate = self
        genderSelectionVC.selectedGender = self.lblGender.text
        genderSelectionVC.isHideOther = false
        view.addSubview(genderSelectionVC.view)
        addChild(genderSelectionVC)
    }

    @IBAction private func btnCountryClicked(_ btnSender: UIButton) {
        
        if(self.arrCountryList.count > 0) {
            let countrySelectionVC = storyboard?.instantiateViewController(withIdentifier: "CountrySelectionVC") as! CountrySelectionVC
            countrySelectionVC.arrCountry = self.arrCountryList
            countrySelectionVC.delegate = self
            view.addSubview(countrySelectionVC.view)
            addChild(countrySelectionVC)
        }
    }
    
    @IBAction private func btnSearchCallClicked(_ btnSender: UIButton) {
        let searchCallVC = storyboard?.instantiateViewController(withIdentifier: "SearchCallVC") as! SearchCallVC
        searchCallVC.strCountry = lblCountry.text
        searchCallVC.strGender = lblGender.text
        self.navigationController?.pushViewController(searchCallVC, animated: true)
    }
    
}

extension HomeCallVC: CountrySelectionDelegate {
    
    func selectedCountry(_ strCountry: String?) {
        self.lblCountry.text = strCountry
    }
    
}

extension HomeCallVC: GenderSelectionDelegate {
    
    func selectedGender(_ strGender: String?) {
        self.lblGender.text = strGender
    }
    
}

extension HomeCallVC {
    
    //MARK: - Validation helpers
    private func isValid(userName: String?) -> Bool {
        let characterSet = CharacterSet.whitespaces
        let trimmedText = userName?.trimmingCharacters(in: characterSet)
        let regularExtension = LoginNameRegularExtention.user
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let isValid = predicate.evaluate(with: trimmedText)
        return isValid
    }
    
    private func isValid(login: String?) -> Bool {
        let characterSet = CharacterSet.whitespaces
        let trimmedText = login?.trimmingCharacters(in: characterSet)
        let regularExtension = LoginNameRegularExtention.passord
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let isValid: Bool = predicate.evaluate(with: trimmedText)
        return isValid
    }
    
    
}
