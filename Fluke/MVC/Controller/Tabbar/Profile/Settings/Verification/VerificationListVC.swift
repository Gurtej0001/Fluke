//
//  VerificationListVC.swift
//  Fluke
//
//  Created by JP on 06/06/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class VerificationListVC: UIViewController {
    
    @IBOutlet private weak var tblList: UITableView!
    
    let arrOptions:[String] = ["Email Verification", "Upload Selfi With Proof"]
    let arrIcons:[UIImage] = [#imageLiteral(resourceName: "emailVerify"), #imageLiteral(resourceName: "photoVerify")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        tblList.tableFooterView = UIView()
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension VerificationListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: VerifyListTC = tableView.dequeueReusableCell(withIdentifier: "VerifyListTC") as! VerifyListTC
        
        cell.ivImageLogo.image = arrIcons[indexPath.row]
        cell.lblTitle.text = arrOptions[indexPath.row]
        cell.ivBagdge.isHidden = true
        
        if(indexPath.row == 0 && UserModel.sharedUser.strEmailVerifiedStatus == "Verified") {
            cell.ivBagdge.isHidden = false
        }
        else if(indexPath.row == 1 && UserModel.sharedUser.strPhotoIDVerifiedStatus == "Verified") {
            cell.ivBagdge.isHidden = false
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == 0 && UserModel.sharedUser.strEmailVerifiedStatus != "Verified") {
            let emailVerifyVC = storyboard?.instantiateViewController(withIdentifier: "EmailVerifyVC") as! EmailVerifyVC
            self.navigationController?.pushViewController(emailVerifyVC, animated: true)
        }
        else if(indexPath.row == 1 && UserModel.sharedUser.strPhotoIDVerifiedStatus != "Verified") {
            let selfiVerifyVC = storyboard?.instantiateViewController(withIdentifier: "SelfiVerifyVC") as! SelfiVerifyVC
            self.navigationController?.pushViewController(selfiVerifyVC, animated: true)
        }
        else {
            self.showAlert(strMsg: "Already verified")
        }
    }
        
}
