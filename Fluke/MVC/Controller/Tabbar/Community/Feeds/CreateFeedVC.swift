//
//  CreateFeedVC.swift
//  Fluke
//
//  Created by JP on 16/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation

class CreateFeedVC: UIViewController {
    
    @IBOutlet private weak var viewUpload: UIView!
    @IBOutlet private weak var cvPhotoList: UICollectionView!
    @IBOutlet private weak var tvComment: UITextView!
    
    private var arrImageObj = [FeedImageModel]()
    
    var feedDetails: FeedModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        
        if(feedDetails == nil) {
            feedDetails = FeedModel()
        }
        else {
            self.setAllValues()
        }
        
        self.cvPhotoList.layer.cornerRadius = 4
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.viewUpload.addDashedBorder()
        }
        
    }
    
    private func setAllValues() {
        self.tvComment.text = feedDetails.strComment
        self.arrImageObj = feedDetails.arrFeedImages
        
        for path in arrImageObj {
            
            do {
                let data = try Data(contentsOf: URL(string: path.strUrl)!)
                
                let mediaDetails = FeedImageModel()
                mediaDetails.mediaData = data
                mediaDetails.isVideo = path.isVideo
                
                self.arrImageObj.append(mediaDetails)
            } catch {
                print("do it error")
            }
        }
        
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction private func btnPost(_btnSender: UIButton) {
        self.view.endEditing(true)
        
        if(IsEmpty(strText: tvComment.text) == true) {
            self.showAlert(strMsg: "Add comment")
        }
        else {
         
            if(arrImageObj.count > 0) {
                SVProgressHUD.show(withStatus: "upload media 1")
                self.uploadImages(index: 0)
            }
            else {
                self.callAPIs()
            }
            
        }
    }
    
    @IBAction private func btnAddNewImage(_btnSender: UIButton) {
        
        self.view.endEditing(true)
        
        var videoCount = 0
        
        for details in self.arrImageObj {
            if(details.isVideo == true) {
                videoCount = videoCount + 1
            }
        }
        
        
        if(arrImageObj.count == 4) {
            self.showAlert(strMsg: "You can select maximum four media with one video")
        }
        else if(videoCount > 0) {
            
            let picker = ImagePickerManager()
            
            picker.pickImage(self, type: .photo) { (imageData, isVideo) in
                let mediaDetails = FeedImageModel()
                mediaDetails.mediaData = imageData
                mediaDetails.isVideo = isVideo
                self.arrImageObj.append(mediaDetails)
                self.cvPhotoList.reloadData()
            }
            
        }
        else {
            let picker = ImagePickerManager()
            
            picker.pickImage(self, type: .both) { (imageData, isVideo) in
                let mediaDetails = FeedImageModel()
                mediaDetails.mediaData = imageData
                mediaDetails.isVideo = isVideo
                self.arrImageObj.append(mediaDetails)
                self.cvPhotoList.reloadData()
            }
        }
    }
    
    @IBAction private func btnDeleteImage(_btnSender: UIButton) {
        self.view.endEditing(true)
        self.arrImageObj.remove(at: _btnSender.tag)
        self.cvPhotoList.reloadData()
    }
    
    private func uploadImages(index: Int) {
        
        let details = arrImageObj[index]
        var type = "image/jpeg"
        
        if(details.isVideo == true) {
            type = "video/mp4"
        }
        
        S3Manager.sharedS3Manager.uploadFile(with: details.mediaData, type: type, folderName: "feed/", success: { (strURL) in
            
            let temp = self.arrImageObj[index]
            temp.strUrl = strURL
            
            if(self.arrImageObj.count == index+1) {
                self.callAPIs()
            }
            else {
                SVProgressHUD.show(withStatus: "upload image \(index+2)")
                self.uploadImages(index: index+1)
            }
            
        }) { (strError) in
            self.showAlert(strMsg: strError!)
            self.arrImageObj.removeAll()
            SVProgressHUD.dismiss()
        }
    }
    
    private func callAPIs() {

        DispatchQueue.main.async {
            self.feedDetails.addNewFeed(strComment: self.tvComment.text!, arrURLs: self.arrImageObj, success: { (response) in
                SVProgressHUD.dismiss()
                self.showAlertWithBackController(strMsg: "Feed added")
            }) { (strError) in
                SVProgressHUD.dismiss()
            }
        }
    }    
}

extension CreateFeedVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImageObj.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FeedPhotosCC = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedPhotosCC", for: indexPath) as! FeedPhotosCC
        cell.btnDelete.tag = indexPath.row
        
        let details = arrImageObj[indexPath.row]
        
        if(details.isVideo == true) {
            cell.btnPlay.isHidden = false
            cell.ivImage.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.2431372549, blue: 0.568627451, alpha: 1)
        }
        else {
            cell.btnPlay.isHidden = true
            cell.ivImage.image = UIImage(data: details.mediaData)!
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.view.frame.size.width - 84)/3
        return CGSize(width: width, height: width)
    }
    
}

extension UIView {
    
    func addDashedBorder() {
        let color = UIColor.black.withAlphaComponent(0.4).cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 4).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}
