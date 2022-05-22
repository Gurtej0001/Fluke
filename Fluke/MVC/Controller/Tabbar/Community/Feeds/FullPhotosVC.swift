//
//  FullPhotosVC.swift
//  Fluke
//
//  Created by JP on 05/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import Quickblox
import AVFoundation
import AVKit

class FullPhotosVC: UIViewController {

    @IBOutlet private weak var photoList: UICollectionView!
    var imageObjs:[FeedImageModel]!
    var qbChatAttachment:[QBChatAttachment]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func btnCloseClicked(_ btnSender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func btnPlayClicked(_ btnSender: UIButton) {
        
        
        if(imageObjs != nil) {
            let videoURL = NSURL(string: imageObjs[btnSender.tag].strUrl)
            let player = AVPlayer(url: videoURL! as URL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
}

extension FullPhotosVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(imageObjs != nil) {
            return imageObjs.count
        }
        else {
            return qbChatAttachment.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FullPhotoCC = collectionView.dequeueReusableCell(withReuseIdentifier: "FullPhotoCC", for: indexPath) as! FullPhotoCC
        
        cell.btnPlay.tag = indexPath.row
        
        if(imageObjs != nil) {
            
            if(imageObjs[indexPath.row].isVideo == true) {
                cell.btnPlay.isHidden = false
                getThumbnailImageFromVideoUrl(url: URL(string: imageObjs[indexPath.row].strUrl)!) { (image) in
                    cell.ivPhoto.image = image
                }
            }
            else {
                cell.btnPlay.isHidden = true
                setImagefromURL(ivImage: cell.ivPhoto, strUrl: imageObjs[indexPath.row].strUrl)
            }
            
        }
        else {
            cell.btnPlay.isHidden = true
            setImagefromURL(ivImage: cell.ivPhoto, strUrl: qbChatAttachment[indexPath.row].url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
}
