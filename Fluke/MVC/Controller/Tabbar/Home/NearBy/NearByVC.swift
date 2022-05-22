//
//  NearByVC.swift
//  Fluke
//
//  Created by JP on 28/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

class NearByVC: UIViewController {

    @IBOutlet private weak var cvList:UICollectionView!
    @IBOutlet private weak var lblGender:UILabel!
    private var refresher:UIRefreshControl!
    
    private var isLoadingAPIList : Bool = false
    
    private var objNearBy = NearByModel()
    private var arrList = [NearByModel]()
    private var strGender = Constant.Gender.MALE()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UserModel.sharedUser.strGender == Constant.Gender.OTHER()) {
            strGender = Constant.Gender.OTHER()
        }
        else if(UserModel.sharedUser.strGender == Constant.Gender.MALE()) {
            strGender = Constant.Gender.FEMALE()
        }
        else {
            strGender = Constant.Gender.MALE()
        }
        
        lblGender.text = strGender
        
        self.refresher = UIRefreshControl()
        self.cvList.alwaysBounceVertical = true
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.cvList.addSubview(refresher)
        
        self.getAllList(strPage: "1", strGender: strGender)
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
       self.getAllList(strPage: "1", strGender: strGender)
    }
    
    private func getAllList(strPage: String, strGender: String) {
        
        objNearBy.getListOfNewarBy(strPage: strPage, strLat: UserModel.sharedUser.strLat, strLong: UserModel.sharedUser.strLat, strGender: strGender, success: { (arrResponse) in
            
            DispatchQueue.main.async {
                self.refresher.endRefreshing()
                self.isLoadingAPIList = false
                
                if(strPage == "1") {
                    self.arrList = arrResponse
                }
                else {
                    self.arrList.append(contentsOf: arrResponse)
                }
                
                self.cvList.reloadData()
            }
            
        }) { (strError) in
            self.refresher.endRefreshing()
            self.isLoadingAPIList = false
            self.showAlert(strMsg: strError!)
        }
    }
    
    @IBAction private func btnGenderClicked(_ btnSender: UIButton) {
        
        let genderSelectionVC = storyboard?.instantiateViewController(withIdentifier: "GenderSelectionVC") as! GenderSelectionVC
        genderSelectionVC.selectedGender = lblGender.text
        genderSelectionVC.delegate = self
        genderSelectionVC.isHideOther = false
        view.addSubview(genderSelectionVC.view)
        addChild(genderSelectionVC)
    }
}

extension NearByVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: NearByCC = collectionView.dequeueReusableCell(withReuseIdentifier: "NearByCC", for: indexPath) as! NearByCC
        
        let details = arrList[indexPath.row]
        
        setImagefromURL(ivImage: cell.ivImage, strUrl: details.strProfileImage)
        cell.lblName.text = details.getDisplayName()
        cell.lblYear.text = "\(details.distance)\n\(details.strUserAge)"
        cell.lblYear.numberOfLines = 2
        cell.ivBadge.isHidden = !details.isVerify
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width - 56)/2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        let details = arrList[indexPath.row]
        
        let otherUserProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileVC
        otherUserProfileVC.userId = details.strId
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        
        
//        SVProgressHUD.show(withStatus: "Fetch details...")
//
//        QBManager.sharedManager.createChatDialog(strUserId: arrList[indexPath.row].strId, success: { (dialog) in
//
//            SVProgressHUD.dismiss()
//
//            let otherUserProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileVC
//            otherUserProfileVC.chatdialog = dialog[Constant.ChatDialogDetails.ChatDialog()] as? QBChatDialog
//            otherUserProfileVC.userDetails = dialog[Constant.ChatDialogDetails.OtherUser()] as? QBUUser
//            self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
//        }) { (strError) in
//
//        }
    }
}

extension NearByVC: GenderSelectionDelegate {
    
    func selectedGender(_ strGender: String?) {
        
        if(strGender != self.strGender) {
            self.strGender = strGender!
            lblGender.text = strGender
            
            self.getAllList(strPage: "1", strGender: strGender!)
        }
    }
}

extension NearByVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingAPIList){
            
            let record = self.arrList.last
            
            if(record?.strTotalPage != record?.strCurrentPage) {
                self.isLoadingAPIList = true
                let newPage = Int(record!.strCurrentPage)! + 1
                self.getAllList(strPage: "\(newPage)", strGender: strGender)
            }
        }
    }
}
