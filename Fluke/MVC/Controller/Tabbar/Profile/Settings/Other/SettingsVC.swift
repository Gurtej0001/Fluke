//
//  SettingsVC.swift
//  Fluke
//
//  Created by JP on 15/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet private weak var tblList: UITableView!
    
    let arrOptions:[String] = ["Privacy Policy", "Terms & Conditions", "Change Password", "Do not disturb", "Verify Profile", "Subscription", "Block List", "Contact Us", "Logout"]
    let arrIcons:[UIImage] = [#imageLiteral(resourceName: "iconTerms"), #imageLiteral(resourceName: "iconTerms"), #imageLiteral(resourceName: "iconPrivacy"), #imageLiteral(resourceName: "iconSupport"), #imageLiteral(resourceName: "iconPrivacy"), #imageLiteral(resourceName: "subscription"), #imageLiteral(resourceName: "ic_blocklist"), #imageLiteral(resourceName: "ContactUsN"), #imageLiteral(resourceName: "logout")]
    
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


extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: SettingsTC = tableView.dequeueReusableCell(withIdentifier: "SettingsTC") as! SettingsTC
        
        cell.ivImageLogo.image = arrIcons[indexPath.row]
        cell.lblTitle.text = arrOptions[indexPath.row]
        cell.ivNextArrow.isHidden = false
        cell.swSwitch.isHidden = true
        
        if(indexPath.row == 3) {
            cell.ivNextArrow.isHidden = true
            cell.swSwitch.isHidden = false
            cell.swSwitch.isOn = UserModel.sharedUser.isDND
        }
        
        if(indexPath.row == 7) {
            cell.ivNextArrow.isHidden = true
            cell.swSwitch.isHidden = true
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row < 2) {
            let staticVC = storyboard?.instantiateViewController(withIdentifier: "StaticVC") as! StaticVC
            staticVC.strTitle = arrOptions[indexPath.row]
            
            if(indexPath.row == 0) {
                staticVC.strSlug = "privacypolicy"
            }
            else if(indexPath.row == 1) {
                staticVC.strSlug = "terms&conditions"
            }
            
            self.navigationController?.pushViewController(staticVC, animated: true)
        }
        else if(indexPath.row == 2) {
            let changePassVC = storyboard?.instantiateViewController(withIdentifier: "ChangePassVC") as! ChangePassVC
            self.navigationController?.pushViewController(changePassVC, animated: true)
        }
        else if(indexPath.row == 4) {
            let verificationListVC = storyboard?.instantiateViewController(withIdentifier: "VerificationListVC") as! VerificationListVC
            self.navigationController?.pushViewController(verificationListVC, animated: true)
        }
        else if(indexPath.row == 5) {
            let inAppVC = storyboard?.instantiateViewController(withIdentifier: "InAppVC") as! InAppVC
            self.navigationController?.pushViewController(inAppVC, animated: true)
        }
        else if(indexPath.row == 6) {
            let blockListVC = storyboard?.instantiateViewController(withIdentifier: "BlockListVC") as! BlockListVC
            self.navigationController?.pushViewController(blockListVC, animated: true)
        }
        else if(indexPath.row == 7) {
            let contactMsgVC = storyboard?.instantiateViewController(withIdentifier: "ContactMsgVC") as! ContactMsgVC
            self.navigationController?.pushViewController(contactMsgVC, animated: true)
        }
        else if(indexPath.row == 8) {
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: appName, message: "Are you sure you want to logout?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    
                    UserModel.sharedUser.logoutUser(success: { (user) in
                        
                        DispatchQueue.main.async {
                            UserModel.sharedUser.strId = ""
                            let animationVC = self.storyboard!.instantiateViewController(withIdentifier: "AnimationVC") as! AnimationVC
                            let nav = UINavigationController.init(rootViewController: animationVC)
                            nav.navigationBar.isHidden = true
                            appDelegate.window?.rootViewController = nav
                        }
                        
                    }) { (strError) in
                        self.showAlert(strMsg: strError!)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    @IBAction func changeDND(swSwitch: UISwitch) {
        UserModel.sharedUser.isDND = !UserModel.sharedUser.isDND
        
        UserModel.sharedUser.setDND(success: { (userModel) in
            
            QBManager.sharedManager.updateUserDND(strDNDStatus: "\(UserModel.sharedUser.isDND)", strPlanId: "0")
            
        }) { (strError) in
            self.showAlert(strMsg: strError!)
            UserModel.sharedUser.isDND = !UserModel.sharedUser.isDND
            swSwitch.isOn = !swSwitch.isOn
        }
        
    }
    
    
}
