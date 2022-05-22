//
//  EditProfileVC.swift
//  Fluke
//
//  Created by JP on 14/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import GooglePlaces

class EditProfileVC: UIViewController {

    @IBOutlet private var txtFirstName: UITextField!
    @IBOutlet private var txtLastName: UITextField!
    @IBOutlet private var txtEmail: UITextField!
    @IBOutlet private var txtUserName: UITextField!
    
    @IBOutlet private var tvAbout: UITextView!
    
    @IBOutlet private var lblGender: UILabel!
    @IBOutlet private var lblDOB: UILabel!
    @IBOutlet private var lblCountry: UILabel!
    @IBOutlet private var lblCity: UILabel!
    
    
    @IBOutlet private var viewFirstName: UIView!
    @IBOutlet private var viewLastName: UIView!
    @IBOutlet private var viewDisplayName: UIView!
    @IBOutlet private var viewEmail: UIView!
    @IBOutlet private var viewAbout: UIView!
    @IBOutlet private var viewGender: UIView!
    @IBOutlet private var viewDob: UIView!
    @IBOutlet private var viewCountry: UIView!
    @IBOutlet private var viewCity: UIView!
    
    @IBOutlet private var ivImage: UIImageView!
    @IBOutlet private var btnEdit: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        
        self.setViewBorder(viewFirstName)
        self.setViewBorder(viewLastName)
        self.setViewBorder(viewEmail)
        self.setViewBorder(viewAbout)
        self.setViewBorder(viewGender)
        self.setViewBorder(viewDob)
        self.setViewBorder(viewCountry)
        self.setViewBorder(viewCity)
        self.setViewBorder(viewDisplayName)
        
        ivImage.layer.cornerRadius = ivImage.frame.size.width/2
        btnEdit.layer.cornerRadius = 4
        
        
        self.txtFirstName.text = UserModel.sharedUser.strUserFirstName
        self.txtLastName.text = UserModel.sharedUser.strUserLastName
        self.txtUserName.text = UserModel.sharedUser.strUserDisplayName
        self.txtEmail.text = UserModel.sharedUser.strEmailId
        self.tvAbout.text = UserModel.sharedUser.strAboutMe
        self.lblGender.text = UserModel.sharedUser.strGender
        self.lblDOB.text = UserModel.sharedUser.strAgeorDOB
        self.lblCountry.text = UserModel.sharedUser.strUserCountry
        self.lblCity.text = UserModel.sharedUser.strUserCity
        
        setImagefromURL(ivImage: ivImage, strUrl: UserModel.sharedUser.strProfileImage)
    }
    
    private func setViewBorder(_ view: UIView) {
        view.layer.cornerRadius = 8.0
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        view.layer.borderWidth = 0.5
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnEditPhotoClicked(_btnSender: UIButton) {
        self.view.endEditing(true)
        
        let picker = ImagePickerManager()
        
        picker.pickImage(self, type: .photo) { (imageData, isVideo) in
            self.ivImage.image = UIImage(data: imageData)
            
            S3Manager.sharedS3Manager.uploadFile(with: imageData, type: "image/jpeg", folderName: "profilePhoto/", success: { (strURL) in
                UserModel.sharedUser.strProfileImage = strURL
            }) { (strError) in
                
            }
        }
    }
    
    @IBAction private func btnGenderClicked(_btnSender: UIButton) {

        self.view.endEditing(true)
        
        let genderSelectionVC = storyboard?.instantiateViewController(withIdentifier: "GenderSelectionVC") as! GenderSelectionVC
        genderSelectionVC.selectedGender = self.lblGender.text
        genderSelectionVC.delegate = self
        genderSelectionVC.isHideOther = true
        view.addSubview(genderSelectionVC.view)
        addChild(genderSelectionVC)
        
    }
    
    @IBAction private func btnDobClicked(_btnSender: UIButton) {
        self.view.endEditing(true)
        
        RPicker.selectDate(title: Constant.SelectDOB(), cancelText: Constant.BtnCancel(), doneText: Constant.BtnDone(), datePickerMode: .date, selectedDate: Date(), minDate: nil, maxDate: Date()) { (date) in
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let myString = formatter.string(from: date)
            let yourDate = formatter.date(from: myString)
            formatter.dateFormat = "yyyy-MM-dd"
            
            self.lblDOB.text = formatter.string(from: yourDate!)
        }
        
    }
    
    @IBAction private func btnCityClicked(_ btnSender: UIButton) {
        self.view.endEditing(true)
        
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
    }
    
    @IBAction private func btnCountryClicked(_ btnSender: UIButton) {
        self.view.endEditing(true)
        
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
    }
    
    @IBAction private func btnUpdateProfileClicked(_btnSender: UIButton) {
        self.view.endEditing(true)
        
        if(IsEmpty(strText: txtFirstName.text)) {
            self.showAlert(strMsg: Constant.EmptyFirstName())
        }
        else if(IsEmpty(strText: txtLastName.text)) {
            self.showAlert(strMsg: Constant.EmptyLastName())
        }
        else if(IsEmpty(strText: tvAbout.text)) {
            self.showAlert(strMsg: Constant.EmptyAbout())
        }
        else {
         
            UserModel.sharedUser.strUserCountry = lblCountry.text ?? ""
            UserModel.sharedUser.strUserCity = lblCity.text ?? ""
            UserModel.sharedUser.strAgeorDOB = lblDOB.text ?? ""
            UserModel.sharedUser.strGender = lblGender.text ?? ""
            UserModel.sharedUser.strAboutMe = tvAbout.text ?? ""
            
            UserModel.sharedUser.strEmailId = txtEmail.text ?? ""
            UserModel.sharedUser.strUserLastName = txtLastName.text ?? ""
            UserModel.sharedUser.strUserFirstName = txtFirstName.text ?? ""
            UserModel.sharedUser.strUserDisplayName = txtUserName.text ?? ""
            
            UserModel.sharedUser.strProfileImage = UserModel.sharedUser.strProfileImage
            
            UserModel.sharedUser.updateUser(success: { (response) in
                
                QBManager.sharedManager.updateFullName(fullName: UserModel.sharedUser.getDisplayName())
                
                self.showAlertWithBackController(strMsg: "Profile updated")
            }) { (strError) in
                self.showAlert(strMsg: strError!)
            }
            
        }
    }
}


extension EditProfileVC: GenderSelectionDelegate {
    func selectedGender(_ strGender: String?) {
        self.lblGender.text = strGender
    }
}

class GoogleLocation {

    var lat, lng: Double?
    var city, state, country, name: String?

    func extractFromGooglePlcae(place: GMSPlace) -> GoogleLocation {
        self.lat = place.coordinate.latitude
        self.lng = place.coordinate.longitude
        self.city = place.name!
        self.state = place.addressComponents?.first(where: { $0.type == "administrative_area_level_1" })?.name
        self.country = place.addressComponents?.first(where: { $0.type == "country" })?.name

        return self
    }

}



extension EditProfileVC: GMSAutocompleteViewControllerDelegate {

    
  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    //print("Place: \(place)")
    
    let googleLocation = GoogleLocation().extractFromGooglePlcae(place: place)
    lblCountry.text = googleLocation.country
    lblCity.text = googleLocation.city
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
