//
//  FeedListVC.swift
//  Fluke
//
//  Created by JP on 15/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class FeedListVC: UIViewController {

    @IBOutlet private weak var tblList: UITableView!
    private var arrFeedList = [FeedModel]()
    private var refreshControl = UIRefreshControl()

    private var isLoadingAPIList : Bool = false
    private var objFeedModel = FeedModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAllFeedList(strPage: "1")
        self.tblList.rowHeight = UITableView.automaticDimension
        self.tblList.estimatedRowHeight = 44.0
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tblList.reloadData()
    }
    
    private func setupUI() {
        self.tblList.tableHeaderView = UIView()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tblList.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
       self.getAllFeedList(strPage: "1")
    }
    
    private func getAllFeedList(strPage: String) {
        
        objFeedModel.getListOfFeedBy(strPage: strPage, success: { (arrResponse) in
            
            DispatchQueue.main.async {
                
                self.refreshControl.endRefreshing()
                
                self.isLoadingAPIList = false
                
                if(strPage == "1") {
                    self.arrFeedList = arrResponse
                }
                else {
                    self.arrFeedList.append(contentsOf: arrResponse)
                }
                
                self.tblList.reloadData()
            }
            
        }) { (strError) in
            self.refreshControl.endRefreshing()
            self.isLoadingAPIList = false
            self.showAlert(strMsg: strError!)
        }
    }
    
    @IBAction private func btnCreatePost(_btnSender: UIBarButtonItem) {
        
        if(UserModel.sharedUser.strPlanId == "1") {
            let createFeedVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateFeedVC") as! CreateFeedVC
            self.navigationController?.pushViewController(createFeedVC, animated: false)
        }
        else {
            DispatchQueue.main.async {
                self.showAlert(strMsg: "You have to subscribe call feature")
            }
        }
    }
        
    @IBAction func openProfilePhoto(_btnSender: UIButton) {
        
        let details = arrFeedList[_btnSender.tag]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fullPhotosVC = storyboard.instantiateViewController(withIdentifier: "FullPhotosVC") as! FullPhotosVC
        
        let temp = FeedImageModel()
        temp.strFeedId = ""
        temp.strUrl = ""

        if (details.userDetails.strProfileImage != nil) {
            temp.strUrl = details.userDetails.strProfileImage
        }
        
        temp.strImageId = ""
        temp.isVideo = false
        temp.mediaData = Data()
        
        fullPhotosVC.imageObjs = [temp]
        let nav = UINavigationController.init(rootViewController: fullPhotosVC)
        nav.navigationBar.isHidden = true
        self.navigationController!.present(nav, animated: true, completion: nil)
        
    }
    
    @IBAction private func btnViewProfile(_btnSender: UIButton) {
        let details = arrFeedList[_btnSender.tag]
  
        let otherUserProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileVC
        otherUserProfileVC.userId = details.userDetails.strId
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
    }
    
    @IBAction private func btnReportFeed(_btnSender: UIButton) {
        
        let reportFeed = storyboard?.instantiateViewController(withIdentifier: "ReportFeed") as! ReportFeed
        reportFeed.feedDetails = arrFeedList[_btnSender.tag]
        //view.addSubview(reportFeed.view)
        //addChild(reportFeed)
        self.navigationController?.pushViewController(reportFeed, animated: true)
    }
    
    @IBAction private func btnLikeFeed(_btnSender: UIButton) {
        
        _btnSender.isSelected = !_btnSender.isSelected
        
        let details = arrFeedList[_btnSender.tag]
        if(details.isLike == true) {
            details.isLike = false
            details.strLikeCount = "\(Int(details.strLikeCount)! - 1)"
        }
        else {
            details.isLike = true
            details.strLikeCount = "\(Int(details.strLikeCount)! + 1)"
        }
        
        DispatchQueue.main.async {
            self.tblList.reloadRows(at: [IndexPath(row: _btnSender.tag, section: 0)], with: .automatic)
        }
        
        details.likeFeed(success: { (details) in
            
        }) { (strError) in
            _btnSender.isSelected = !_btnSender.isSelected
            
            if(details.isLike == true) {
                details.isLike = false
                details.strLikeCount = "\(Int(details.strLikeCount)! - 1)"
            }
            else {
                details.isLike = true
                details.strLikeCount = "\(Int(details.strLikeCount)! + 1)"
            }
            
            DispatchQueue.main.async {
                self.tblList.reloadRows(at: [IndexPath(row: _btnSender.tag, section: 0)], with: .automatic)
                self.showAlert(strMsg: strError!)
            }
        }
        
    }
    
}

extension FeedListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFeedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let details = arrFeedList[indexPath.row]
        
        if(details.arrFeedImages.count == 0) {
            let cell: FeedTextTC = tableView.dequeueReusableCell(withIdentifier: "FeedTextTC") as! FeedTextTC
            cell.btnProfilePhoto.tag = indexPath.row
            cell.btnUserName.tag = indexPath.row
            cell.btnLike.tag = indexPath.row
            cell.setAllValues(details)
            return cell
        }
        else {
            let cell: FeedTC = tableView.dequeueReusableCell(withIdentifier: "FeedTC") as! FeedTC
            cell.btnLike.tag = indexPath.row
            cell.btnProfilePhoto.tag = indexPath.row
            cell.btnUserName.tag = indexPath.row
            cell.setAllValues(details)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedDetailsVC") as! FeedDetailsVC
        feedDetailsVC.feedDetails = arrFeedList[indexPath.row]
        self.navigationController?.pushViewController(feedDetailsVC, animated: true)
    }
    
}

extension FeedListVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingAPIList){
            
            let record = self.arrFeedList.last
            
            if(record?.strTotalPage != record?.strCurrentPage) {
                self.isLoadingAPIList = true
                let newPage = Int(record!.strCurrentPage)! + 1
                self.getAllFeedList(strPage: "\(newPage)")
            }
        }
    }
}
