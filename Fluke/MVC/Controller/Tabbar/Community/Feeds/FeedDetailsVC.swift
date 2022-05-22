//
//  FeedDetailsVC.swift
//  Fluke
//
//  Created by JP on 05/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class FeedDetailsVC: UIViewController {
    
    @IBOutlet private weak var tblList: UITableView!
    
    @IBOutlet weak var constantHightOfSendView: NSLayoutConstraint!
    @IBOutlet weak var constantBottomOfSendview: NSLayoutConstraint!
    @IBOutlet weak var tvMsg: UITextView!
    
    @IBOutlet weak var viewBottomMsg: UIView!
    @IBOutlet weak var viewMsg: UIView!
    @IBOutlet weak var btnSend: UIButton!
    
    private var isLoadingAPIList : Bool = false
    private var refreshControl = UIRefreshControl()
    
    var feedDetails: FeedModel!
    var arrComments = [CommentModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setAllValues()
        self.getComments(strPage: "1")
        
        //if(UserModel.sharedUser.strPlanId == "0") {
//            self.constantHightOfSendView.constant = 0
        //}
    }
    
    private func setupUI() {
        self.tblList.tableFooterView = UIView()
        
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(FeedDetailsVC.keyboardOnScreen(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notiCenter.addObserver(self, selector: #selector(FeedDetailsVC.keyboardOffScreen(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.viewBottomMsg.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.viewBottomMsg.layer.shadowRadius = 8
        self.viewBottomMsg.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.viewBottomMsg.layer.shadowOpacity = 0.3
        
        self.viewMsg.layer.cornerRadius = 8
        self.btnSend.layer.cornerRadius = 8
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tblList.addSubview(refreshControl)
    }
        
    @objc func refresh(_ sender: AnyObject) {
        self.getComments(strPage: "1")
    }
    
    private func getComments(strPage: String) {
        
        feedDetails.getListOfFeedComment(strPage: strPage, success: { (arrResponse) in
            
            DispatchQueue.main.async {
                
                self.refreshControl.endRefreshing()
                
                self.isLoadingAPIList = false
                
                if(strPage == "1") {
                    self.arrComments = arrResponse
                }
                else {
                    self.arrComments.append(contentsOf: arrResponse)
                }
                
                self.tblList.reloadData()
            }
            
        }) { (strError) in
            self.refreshControl.endRefreshing()
            self.isLoadingAPIList = false
            self.showAlert(strMsg: strError!)
        }
        
    }
    
    private func setAllValues() {
        self.title = feedDetails.getDisplayName()
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnSend(_btnSender: UIButton) {
        
        self.view.endEditing(true)
        
        if(IsEmpty(strText: tvMsg.text) == true) {
            self.showAlert(strMsg: "Enter comment")
        }
        else {
            
            feedDetails.commentFeed(strComment: tvMsg.text!, success: { (response) in
                
                DispatchQueue.main.async {
                    self.arrComments.insert(response, at: 0)
                    self.feedDetails.strCommentCount = "\(Int(self.feedDetails.strCommentCount)! + 1)"
                    self.tblList.reloadData()
                    self.tvMsg.text = ""
                }
                
            }) { (strError) in
                self.showAlert(strMsg: strError!)
            }
            
        }
    }
    
    @IBAction private func btnLikeFeed(_btnSender: UIButton) {
        
        _btnSender.isSelected = !_btnSender.isSelected
        
        if(feedDetails.isLike == true) {
            feedDetails.isLike = false
            feedDetails.strLikeCount = "\(Int(feedDetails.strLikeCount)! - 1)"
        }
        else {
            feedDetails.isLike = true
            feedDetails.strLikeCount = "\(Int(feedDetails.strLikeCount)! + 1)"
        }
        
        DispatchQueue.main.async {
            self.tblList.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        feedDetails.likeFeed(success: { (details) in
            
        }) { (strError) in
            _btnSender.isSelected = !_btnSender.isSelected
            
            if(self.feedDetails.isLike == true) {
                self.feedDetails.isLike = false
                self.feedDetails.strLikeCount = "\(Int(self.feedDetails.strLikeCount)! - 1)"
            }
            else {
                self.feedDetails.isLike = true
                self.feedDetails.strLikeCount = "\(Int(self.feedDetails.strLikeCount)! + 1)"
            }
            
            DispatchQueue.main.async {
                self.tblList.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.showAlert(strMsg: strError!)
            }
        }
        
    }
    
    
    @IBAction func viewUserProfile(_btnSender: UIButton) {
        
        let details = arrComments[_btnSender.tag-1]
        
        let otherUserId = details.userDetails.strId

        let otherUserProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileVC
        otherUserProfileVC.userId = otherUserId
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        
    }
    
    @IBAction func openProfilePhoto(_btnSender: UIButton) {
        
        let details = arrComments[_btnSender.tag-1]
        
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
    
}

extension FeedDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrComments.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0) {
            
            if(feedDetails.arrFeedImages.count == 0) {
                let cell: FeedDetailsTextHeadeTC = tableView.dequeueReusableCell(withIdentifier: "FeedDetailsTextHeadeTC") as! FeedDetailsTextHeadeTC
                
                cell.navigation = self.navigationController
                cell.lblDesc.text = feedDetails.strComment
                cell.btnLike.isSelected = feedDetails.isLike
                cell.btnLike.setTitle(feedDetails.strLikeCount, for: .normal)
                cell.lblCommentCount.text = feedDetails.strCommentCount
                cell.btnComment.setTitle(feedDetails.strCommentCount, for: .normal)
                
                return cell
            }
            else {
                let cell: FeedDetailsHeadeTC = tableView.dequeueReusableCell(withIdentifier: "FeedDetailsHeadeTC") as! FeedDetailsHeadeTC
                
                cell.navigation = self.navigationController
                
                cell.lblDesc.text = feedDetails.strComment
                cell.btnLike.isSelected = feedDetails.isLike
                cell.btnLike.setTitle(feedDetails.strLikeCount, for: .normal)
                cell.lblCommentCount.text = feedDetails.strCommentCount
                cell.btnComment.setTitle(feedDetails.strCommentCount, for: .normal)
                cell.page.numberOfPages = feedDetails.arrFeedImages.count
                cell.feedDetails = feedDetails
                cell.photoList.reloadData()
                
                return cell
            }
        }
        else {
            let cell: FeedCommentTC = tableView.dequeueReusableCell(withIdentifier: "FeedCommentTC") as! FeedCommentTC
            
            cell.btnProfile.tag = indexPath.row
            cell.btnUserName.tag = indexPath.row
            
            let details = arrComments[indexPath.row-1]
            
            setImagefromURL(ivImage: cell.ivImage, strUrl: details.userDetails.strProfileImage)
            cell.lblComment.text = details.strComment
            cell.lblTime.text = details.strTime
            cell.lblUserName.text = details.userDetails.getDisplayName()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: - UITextView Delegates
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        if (textView == tvMsg) {
            
            let fixedWidth = tvMsg.frame.size.width
            tvMsg.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = tvMsg.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = tvMsg.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            
            if(newFrame.height < 42) {
                self.constantHightOfSendView.constant = 140
            }
            
            if (newFrame.height < 140) {
                self.constantHightOfSendView.constant = newFrame.height + 58
            }
        }
    }
    

    
    //MARK: - Keyboard Animation
    
    @objc func keyboardOnScreen(sender: NSNotification) {
        
        let offset: CGSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        
        self.constantBottomOfSendview.constant = -offset.height
        
        UIView.animate(withDuration: 0.25,
                                   delay: 0,
                                   usingSpringWithDamping: 500,
                                   initialSpringVelocity: 5.0,
                                   options: UIView.AnimationOptions.curveLinear,
                                   animations: {
                                    self.view.layoutIfNeeded()
            }, completion: { finished in
                
                if(self.arrComments.count > 0) {
//                    let indexPath = IndexPath(row: self.arrComments.count - 1, section: 0)
//                    self.tblList.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.none, animated: true)
                }
        })
    }
    
    @objc func keyboardOffScreen(notification: NSNotification) {
        
        self.constantBottomOfSendview.constant = 0
        
        UIView.animate(withDuration: 0.25,
                                   delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity:0,
                                   options: UIView.AnimationOptions.curveEaseOut,
                                   animations: {
                                    self.view.layoutIfNeeded()
            }, completion: { finished in
                
                if(self.arrComments.count > 0) {
//                    let indexPath = IndexPath(row: self.arrComments.count - 1, section: 0)
//                    self.tblList.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.none, animated: true)
                }
        })
        
    }
}

extension FeedDetailsVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingAPIList){
            
            let record = self.arrComments.last
            
            if(record?.strTotalPage != record?.strCurrentPage) {
                self.isLoadingAPIList = true
                let newPage = Int(record!.strCurrentPage)! + 1
                self.getComments(strPage: "\(newPage)")
            }
        }
    }
}
