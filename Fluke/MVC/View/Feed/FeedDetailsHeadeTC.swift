//
//  FeedDetailsHeadeTC.swift
//  Fluke
//
//  Created by JP on 05/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class FeedDetailsTextHeadeTC: UITableViewCell {

    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblCommentCount: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    
    var navigation: UINavigationController!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}




class FeedDetailsHeadeTC: UITableViewCell {

    @IBOutlet weak var photoList: UICollectionView!
    @IBOutlet weak var page: UIPageControl!
    @IBOutlet weak var lblDesc: UILabel!
    
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblCommentCount: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    
    var navigation: UINavigationController!
    
    var feedDetails: FeedModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension FeedDetailsHeadeTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedDetails.arrFeedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FeedDetailsPhotoCC = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedDetailsPhotoCC", for: indexPath) as! FeedDetailsPhotoCC
        
        if(feedDetails.arrFeedImages[indexPath.row].isVideo == true) {
            getThumbnailImageFromVideoUrl(url: URL(string: feedDetails.arrFeedImages[indexPath.row].strUrl)!) { (image) in
                cell.ivPhoto.image = image
            }
            cell.btnPlay.isHidden = false
        }
        else {
            setImagefromURL(ivImage: cell.ivPhoto, strUrl: feedDetails.arrFeedImages[indexPath.row].strUrl)
            cell.btnPlay.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.page.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let fullPhotosVC = storyboard.instantiateViewController(withIdentifier: "FullPhotosVC") as! FullPhotosVC
        fullPhotosVC.imageObjs = feedDetails.arrFeedImages
        let nav = UINavigationController.init(rootViewController: fullPhotosVC)
        nav.navigationBar.isHidden = true
        navigation.present(nav, animated: true, completion: nil)
    }
    
}
