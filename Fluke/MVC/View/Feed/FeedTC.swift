//
//  FeedCC.swift
//  Fluke
//
//  Created by JP on 15/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class FeedTC: UITableViewCell {

    @IBOutlet private weak var viewProfile: UIView!
    @IBOutlet private weak var viewMainContaint: UIView!
    
    @IBOutlet private weak var viewImges: UIView!
    
    @IBOutlet private weak var ivImage1: UIImageView!//Left Half
    @IBOutlet private weak var ivImage2: UIImageView!//Right Half
    @IBOutlet private weak var ivImage3: UIImageView!//Full Single image
    @IBOutlet private weak var ivImage4: UIImageView!//Right upper half
    @IBOutlet private weak var ivImage5: UIImageView!//Right lower half
    @IBOutlet private weak var ivImage6: UIImageView!//Right upper left half
    @IBOutlet private weak var ivImage7: UIImageView!//Right upper right half
        
    @IBOutlet weak var btnProfilePhoto: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet private weak var lblComment: UILabel!
    @IBOutlet private weak var ivUserImage: UIImageView!
    @IBOutlet private weak var lblTime: UILabel!
    @IBOutlet private weak var lblUserName: UILabel!
    
    override func awakeFromNib() {
        
        self.viewMainContaint.layer.cornerRadius = 8.0
        self.viewMainContaint.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        self.viewMainContaint.layer.borderWidth = 0.5
        
        self.ivUserImage.layer.cornerRadius = self.ivUserImage.frame.size.width/2
        self.viewProfile.layer.cornerRadius = self.viewProfile.frame.size.width/2
        
        self.setImageView(ivImage: ivImage1)
        self.setImageView(ivImage: ivImage2)
        self.setImageView(ivImage: ivImage3)
        self.setImageView(ivImage: ivImage4)
        self.setImageView(ivImage: ivImage5)
        self.setImageView(ivImage: ivImage6)
        self.setImageView(ivImage: ivImage7)
    }
    
    private func setImageView(ivImage: UIImageView) {
        ivImage.layer.cornerRadius = 4
        ivImage.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        ivImage.layer.borderWidth = 0.5
    }
    
    func setAllValues(_ feedDetails: FeedModel) {
                
        setImagefromURL(ivImage: self.ivUserImage, strUrl: feedDetails.userDetails.strProfileImage)
        self.lblUserName.text = feedDetails.getDisplayName()
        self.lblTime.text = feedDetails.strDateAndTime
        
        self.lblComment.text = feedDetails.strComment
        self.btnLike.setTitle(feedDetails.strLikeCount, for: .normal)
        self.btnComment.setTitle(feedDetails.strCommentCount, for: .normal)
        self.btnLike.isSelected = feedDetails.isLike
        
        let intCount = feedDetails.arrFeedImages.count
        
        ivImage1.isHidden = true
        ivImage2.isHidden = true
        ivImage3.isHidden = true
        ivImage4.isHidden = true
        ivImage5.isHidden = true
        ivImage6.isHidden = true
        ivImage7.isHidden = true
        
        if(intCount == 1) {
            ivImage3.isHidden = false
            self.setImage(ivImage: self.ivImage3, details: feedDetails.arrFeedImages[0])
        }
        else if(intCount == 2) {
            ivImage1.isHidden = false
            ivImage2.isHidden = false
            self.setImage(ivImage: self.ivImage1, details: feedDetails.arrFeedImages[0])
            self.setImage(ivImage: self.ivImage2, details: feedDetails.arrFeedImages[1])
        }
        else if(intCount == 3) {
            ivImage1.isHidden = false
            ivImage4.isHidden = false
            ivImage5.isHidden = false
            
            self.setImage(ivImage: self.ivImage1, details: feedDetails.arrFeedImages[0])
            self.setImage(ivImage: self.ivImage4, details: feedDetails.arrFeedImages[1])
            self.setImage(ivImage: self.ivImage5, details: feedDetails.arrFeedImages[2])
            
        }
        else if(intCount == 4) {
            ivImage1.isHidden = false
            ivImage6.isHidden = false
            ivImage7.isHidden = false
            ivImage5.isHidden = false
            
            self.setImage(ivImage: self.ivImage1, details: feedDetails.arrFeedImages[0])
            self.setImage(ivImage: self.ivImage6, details: feedDetails.arrFeedImages[1])
            self.setImage(ivImage: self.ivImage7, details: feedDetails.arrFeedImages[2])
            self.setImage(ivImage: self.ivImage5, details: feedDetails.arrFeedImages[3])
            
        }
    }
    
    private func setImage(ivImage: UIImageView, details: FeedImageModel) {
        
        if(details.isVideo == true) {
            getThumbnailImageFromVideoUrl(url: URL(string: details.strUrl)!) { (image) in
                ivImage.image = image
            }
        }
        else {
            setImagefromURL(ivImage: ivImage, strUrl: details.strUrl)
        }
        
    }
    
}






class FeedTextTC: UITableViewCell {

    @IBOutlet private weak var viewProfile: UIView!
    @IBOutlet private weak var viewMainContaint: UIView!
    
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet private weak var lblComment: UILabel!
    @IBOutlet private weak var ivUserImage: UIImageView!
    @IBOutlet weak var btnProfilePhoto: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet private weak var lblTime: UILabel!
    @IBOutlet private weak var lblUserName: UILabel!
    
    override func awakeFromNib() {
        
        self.viewMainContaint.layer.cornerRadius = 8.0
        self.viewMainContaint.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        self.viewMainContaint.layer.borderWidth = 0.5
        
        self.ivUserImage.layer.cornerRadius = self.ivUserImage.frame.size.width/2
        self.viewProfile.layer.cornerRadius = self.viewProfile.frame.size.width/2
    }
    
    func setAllValues(_ feedDetails: FeedModel) {
                
        setImagefromURL(ivImage: self.ivUserImage, strUrl: feedDetails.userDetails.strProfileImage)
        self.lblUserName.text = feedDetails.getDisplayName()
        self.lblTime.text = feedDetails.strDateAndTime
        
        self.lblComment.text = feedDetails.strComment
        self.btnLike.setTitle(feedDetails.strLikeCount, for: .normal)
        self.btnComment.setTitle(feedDetails.strCommentCount, for: .normal)
        self.btnLike.isSelected = feedDetails.isLike
    }
}
