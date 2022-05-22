//
//  SignUpTwo.swift
//  Fluke
//
//  Created by JP on 24/02/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import GooglePlaces

class SignUpTwo: UIViewController {

    @IBOutlet weak private var btnMale: UIButton!
    @IBOutlet weak private var btnFeMale: UIButton!
    @IBOutlet weak private var btnOther: UIButton!
    
    @IBOutlet weak private var btnDate: UIButton!
    @IBOutlet weak private var btnCountry: UIButton!
    @IBOutlet weak private var btnCity: UIButton!
    
    @IBOutlet weak private var lblDate: UILabel!
    
    @IBOutlet weak private var tvAbout: UITextView!
    
    @IBOutlet weak private var lblCountry: UILabel!
    @IBOutlet weak private var lblCity: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.setGenderButton(btnMale)
        self.setGenderButton(btnFeMale)
        self.setGenderButton(btnOther)
        
        self.setGenderButton(btnDate)
        self.setGenderButton(btnCountry)
        self.setGenderButton(btnCity)
        
        self.setAboutTextView()
        
        UserModel.sharedUser.strAgeorDOB = ""
        self.btnGenderClicked(btnMale)
    }
    
    private func setAboutTextView() {
        tvAbout.layer.cornerRadius = 8.0
        tvAbout.layer.borderColor = tvAbout.tintColor.withAlphaComponent(0.4).cgColor
        tvAbout.layer.borderWidth = 0.5
    }
    
    private func setGenderButton(_ btnGender: UIButton) {
        btnGender.layer.cornerRadius = 8.0
        btnGender.layer.borderColor = btnGender.tintColor.withAlphaComponent(0.4).cgColor
        btnGender.layer.borderWidth = 0.5
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
            UserModel.sharedUser.strGender = Constant.Gender.MALE()
        }
        else if(btnGender == btnFeMale) {
            UserModel.sharedUser.strGender = Constant.Gender.FEMALE()
        }
        else {
            UserModel.sharedUser.strGender = Constant.Gender.OTHER()
        }
    }
    
    private func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = self.navigationController?.viewControllers.filter({$0.isKind(of: ofClass)}).last {
            self.navigationController?.popToViewController(vc, animated: animated)
        }
    }
    
    @IBAction private func btnLoginClicked(_ btnSender: UIButton) {
        self.popToViewController(ofClass: SignInVC.self, animated: true)
        self.view.endEditing(true)
    }
    
    @IBAction private func btnBackClicked(_ btnSender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnDateClicked(_ btnSender: UIButton) {
        
        let earlyDate = Calendar.current.date(
          byAdding: .year,
          value: -18,
          to: Date())
        
        RPicker.selectDate(title: Constant.SelectDOB(), cancelText: Constant.BtnCancel(), doneText: Constant.BtnDone(), datePickerMode: .date, selectedDate: earlyDate!, minDate: nil, maxDate: earlyDate) { (date) in
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let myString = formatter.string(from: date)
            let yourDate = formatter.date(from: myString)
            formatter.dateFormat = "yyyy-MM-dd"
            
            self.lblDate.text = formatter.string(from: yourDate!)
            
            UserModel.sharedUser.strAgeorDOB = self.lblDate.text ?? ""
        }
    }
    
    @IBAction private func btnProceedClicked(_ btnSender: UIButton) {
        
        if(IsEmpty(strText: UserModel.sharedUser.strAgeorDOB)) {
            self.showAlert(strMsg: Constant.EmptyDOB())
        }
        else if(IsEmpty(strText: tvAbout.text)) {
            self.showAlert(strMsg: Constant.EmptyAbout())
        }
        else {
            
            UserModel.sharedUser.strAboutMe = tvAbout.text!
            
            let signUpThree = storyboard?.instantiateViewController(withIdentifier: "SignUpThree") as! SignUpThree
            self.navigationController?.pushViewController(signUpThree, animated: true)
            self.view.endEditing(true)
            
        }
    }

    @IBAction private func btnCityClicked(_ btnSender: UIButton) {
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
    }
    
    @IBAction private func btnCountryClicked(_ btnSender: UIButton) {
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
    }
    
}


extension SignUpTwo: GMSAutocompleteViewControllerDelegate {

    
  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    //print("Place: \(place)")
    
    let googleLocation = GoogleLocation().extractFromGooglePlcae(place: place)
    lblCountry.text = googleLocation.country
    lblCity.text = googleLocation.city
    
    UserModel.sharedUser.strUserCountry = googleLocation.country!
    UserModel.sharedUser.strUserCity = googleLocation.city!
    
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

}
