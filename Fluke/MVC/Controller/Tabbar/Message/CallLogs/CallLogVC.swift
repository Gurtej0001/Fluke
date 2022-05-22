//
//  CallLogVC.swift
//  Fluke
//
//  Created by JP on 10/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import Quickblox

class CallLogVC: CallExtention {
    
    @IBOutlet weak var tblList: UITableView!
    
    private var arrCalls:[CallModel] = [CallModel]()
    private let objCallModel = CallModel()
    private var isLoadingAPIList : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getListOfAllCalls(strPage: "1")
    }
    
    private func setupUI() {
        self.tblList.tableFooterView = UIView()
    }
    
    private func getListOfAllCalls(strPage: String) {
        
        objCallModel.getCallLogHistory(strPage: strPage, success: { (arrResponse) in
            
            DispatchQueue.main.async {
                self.isLoadingAPIList = false
                
                if(strPage == "1") {
                    self.arrCalls = arrResponse
                }
                else {
                    self.arrCalls.append(contentsOf: arrResponse)
                }
                self.tblList.reloadData()
            }
            
        }) { (strError) in
            self.isLoadingAPIList = false
            self.showAlert(strMsg: strError!)
        }
        
    }
    
    @IBAction func btnBlockClicked(_btnSender: UIButton) {
        
        let details = arrCalls[_btnSender.tag]
        
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let blockUserVC = story.instantiateViewController(withIdentifier: "BlockUserVC") as! BlockUserVC
        
        if(UserModel.sharedUser.strId == details.strCallerId) {//I am caller
            let userProfile = UserModel()
            userProfile.strId = details.reciverUser.strId
            userProfile.strEmailId = details.reciverUser.strEmailId
            userProfile.strUserDisplayName = details.reciverUser.strUserDisplayName
            userProfile.strUserFirstName = details.reciverUser.strUserFirstName
            userProfile.strUserLastName = details.reciverUser.strUserLastName
            userProfile.strProfileImage = details.reciverUser.strProfileImage
            
            blockUserVC.userProfile = userProfile
        }
        else {
            
            let userProfile = UserModel()
            userProfile.strId = details.callerUser.strId
            userProfile.strEmailId = details.callerUser.strEmailId
            userProfile.strUserDisplayName = details.callerUser.strUserDisplayName
            userProfile.strUserFirstName = details.callerUser.strUserFirstName
            userProfile.strUserLastName = details.callerUser.strUserLastName
            userProfile.strProfileImage = details.callerUser.strProfileImage
            
            blockUserVC.userProfile = userProfile
        }
        
        
        self.navigationController?.pushViewController(blockUserVC, animated: true)
    }
    
    @IBAction func btnCallClicked(_btnSender: UIButton) {
        
        let details = arrCalls[_btnSender.tag]
        
        //if(UserModel.sharedUser.strPlanId == "1") {
            
            var otherUserId = ""
            var isDNDOn = true
            var userName = ""
            
            if(UserModel.sharedUser.strId == details.strCallerId) {//I am caller
                otherUserId = details.reciverUser.strId
                isDNDOn = details.reciverUser.isDND
                userName = details.reciverUser.getDisplayName()
            }
            else {
                otherUserId = details.callerUser.strId
                userName = details.callerUser.getDisplayName()
                isDNDOn = details.callerUser.isDND
            }
            
            if(isDNDOn == false) {
                QBManager.sharedManager.createChatDialog(strUserId: otherUserId, success: { (chatDialog) in
                    self.setCallwithUser(with: .video, chatDialog: (chatDialog[Constant.ChatDialogDetails.ChatDialog()] as? QBChatDialog)!, otherUserId: otherUserId)
                }) { (strError) in
                    
                }
            }
            else {
                self.showAlert(strMsg: "\(userName) is not available for a call")
            }
            
//        }
//        else {
//            DispatchQueue.main.async {
//                self.showAlert(strMsg: "You have to subscribe call feature")
//            }
//        }
        
    }
    
    @IBAction func viewUserProfile(_btnSender: UIButton) {
        
        let details = arrCalls[_btnSender.tag]
        var otherUserId = ""
        
        if(UserModel.sharedUser.strId == details.strCallerId) {//I am caller
            otherUserId = details.reciverUser.strId
        }
        else {
            otherUserId = details.callerUser.strId
        }

        let otherUserProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileVC
        otherUserProfileVC.userId = otherUserId
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        
        
    }
    
    @IBAction func openProfilePhoto(_btnSender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fullPhotosVC = storyboard.instantiateViewController(withIdentifier: "FullPhotosVC") as! FullPhotosVC
        
        let temp = FeedImageModel()
        temp.strFeedId = ""
        temp.strUrl = ""

        let callDetails = arrCalls[_btnSender.tag]
        
        if(UserModel.sharedUser.strId == callDetails.strCallerId) {//I am caller
            if (callDetails.reciverUser.strProfileImage != nil) {
                temp.strUrl = callDetails.reciverUser.strProfileImage
            }
        }
        else {//I am receiver
            if (callDetails.callerUser.strProfileImage != nil) {
                temp.strUrl = callDetails.callerUser.strProfileImage
            }
        }
        
        temp.strImageId = ""
        temp.isVideo = false
        temp.mediaData = Data()
        
        fullPhotosVC.imageObjs = [temp]
        let nav = UINavigationController.init(rootViewController: fullPhotosVC)
        nav.navigationBar.isHidden = true
        self.navigationController!.present(nav, animated: true, completion: nil)
        
    }
    
}

extension CallLogVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCalls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CallTC = tableView.dequeueReusableCell(withIdentifier: "CallTC") as! CallTC
        cell.btnProfile.tag = indexPath.row
        cell.btnCall.tag = indexPath.row
        cell.btnBlock.tag = indexPath.row
        cell.btnUserName.tag = indexPath.row
        
        let callDetails = arrCalls[indexPath.row]
        
        if(UserModel.sharedUser.strId == callDetails.strCallerId) {//I am caller
            setImagefromURL(ivImage: cell.ivImage, strUrl: callDetails.reciverUser.strProfileImage)
            cell.lblName.text = callDetails.reciverUser.getDisplayName()
            cell.ivCallTypeImage.image = #imageLiteral(resourceName: "SendCall")
        }
        else {//I am receiver
            setImagefromURL(ivImage: cell.ivImage, strUrl: callDetails.callerUser.strProfileImage)
            cell.lblName.text = callDetails.callerUser.getDisplayName()
            cell.ivCallTypeImage.image = #imageLiteral(resourceName: "RecievcCall")
        }
        
        if(callDetails.strStatus == "MissedCall") {
            cell.lblName.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            cell.lblTime.isHidden = true
        }
        else {
            cell.lblName.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.lblTime.isHidden = false
        }
        
        cell.lblCity.text = callDetails.strCalldateAndTime
        cell.lblTime.text = callDetails.strCallDuration
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension CallLogVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingAPIList){
            
            let record = self.arrCalls.last
            
            if(record?.strTotalPage != record?.strCurrentPage) {
                self.isLoadingAPIList = true
                let newPage = Int(record!.strCurrentPage)! + 1
                self.getListOfAllCalls(strPage: "\(newPage)")
            }
        }
    }
}
