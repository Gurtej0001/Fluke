//
//  SelectAssetsVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 12/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Photos
import PDFKit
import SVProgressHUD

struct PhotoAsset: Equatable {
    var phAsset: PHAsset
    var image: UIImage
    var videoURL: URL?
}

struct SelectAssetsConstant {
    static let maximumMB: Double = 100
    static let dividerToMB: Double = 1048576
    static let minimumSpacing: CGFloat = 8.0
    static let reuseIdentifier = "SelectAssetCellK"
}

class SelectAssetsVC: UIViewController {
    
    var mediaType: PHAssetMediaType!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sendAttachmentButton: UIButton!
    @IBOutlet weak private var collectionView: UICollectionView!
    
    fileprivate var allPhotos: PHFetchResult<AnyObject>?
    
    var selectedAssetCompletion:((_ asset: [PhotoAsset]?) -> Void)?
    var arrSelectedAsset = [PhotoAsset]()
    private var arrCompletedAsset = [PhotoAsset]()
    var arrSelectedIndex = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssets()
    }
    
    private func fetchAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
        fetchOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        allPhotos = nil
        collectionView.reloadData()
        
        if let allPhotos = PHAsset.fetchAssets(with: mediaType, options: fetchOptions) as? PHFetchResult<AnyObject> {
            self.allPhotos = allPhotos
            self.collectionView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.selectedAssetCompletion?(nil)
        }
    }
    
    @IBAction func sendAttachmentButtonTapped(_ sender: UIButton) {

        for indexNumber in arrSelectedIndex {
            
            guard let phAsset = allPhotos?[indexNumber] as? PHAsset else {
                return
            }
            let photoAsset = PhotoAsset(phAsset: phAsset, image: UIImage())
            
            self.arrSelectedAsset.append(photoAsset)
        }
        
        let sendAsset: (Double) -> Void = { [weak self] (size) in
            
            let sizeMB = size/SelectAssetsConstant.dividerToMB
            
            if sizeMB.truncate(to: 2) > SelectAssetsConstant.maximumMB {
                self?.showAlert(strMsg: "The uploaded file exceeds maximum file size (100MB)")
            } else {
                SVProgressHUD.show()
                self?.sendAttachmentButton.isEnabled = false
                
                for selectedAssetUtem in self!.arrSelectedAsset {
                    
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .highQualityFormat
                    
                    PHImageManager.default().requestImage(for: selectedAssetUtem.phAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (image, info) -> Void in
                        
                        SVProgressHUD.dismiss()
                        
                        if let image = image {
                            
                            if(self?.mediaType == .image) {
                                
                                let photoAsset = PhotoAsset(phAsset: selectedAssetUtem.phAsset, image: image, videoURL: nil)
                                DispatchQueue.main.async {
                                    self?.dismiss(animated: true) {
                                        
                                        self!.arrCompletedAsset.append(photoAsset)
                                        
                                        if(self?.arrSelectedIndex.count == self?.arrCompletedAsset.count) {
                                            self?.selectedAssetCompletion?(self!.arrCompletedAsset)
                                        }
                                    }
                                }
                            }
                            else if(self?.mediaType == .video) {
                                
                                PHImageManager.default().requestAVAsset(forVideo: selectedAssetUtem.phAsset, options: nil, resultHandler: { (asset, mix, nil) in
                                    
                                    let myAsset = asset as? AVURLAsset
                                    let photoAsset = PhotoAsset(phAsset: selectedAssetUtem.phAsset, image: image, videoURL: myAsset!.url)
                                    
                                    DispatchQueue.main.async {
                                        self?.dismiss(animated: true) {
                                            
                                            self!.arrCompletedAsset.append(photoAsset)
                                            
                                            if(self?.arrSelectedIndex.count == self?.arrCompletedAsset.count) {
                                                self?.selectedAssetCompletion?(self!.arrCompletedAsset)
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
        
        for selectedAssetItem in arrSelectedAsset {
            
            let res = PHAssetResource.assetResources(for: selectedAssetItem.phAsset)
            if let assetSize = res.first?.value(forKey: "fileSize") as? Double {
                sendAsset(assetSize)
            }
        }
    }
}

extension SelectAssetsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let allPhotos = allPhotos {
            return allPhotos.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SelectAssetCellK, let phAsset = allPhotos?[indexPath.row] as? PHAsset, let size = cell.assetImageView?.bounds.size else {
            return
        }
        
        PHImageManager.default().requestImage(for: phAsset, targetSize: size, contentMode: .aspectFill, options: nil) { (image, info) -> Void in
            if let image = image {
                cell.assetImageView.image = image
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectAssetsConstant.reuseIdentifier, for: indexPath) as? SelectAssetCellK else {
            return UICollectionViewCell()
        }
        
        var myIndex: Int = -1
        
        for element in self.arrSelectedIndex {
            if(element == indexPath.row) {
                myIndex = indexPath.row
                break
            }
        }
        
        if(myIndex != -1) {
            cell.onSelectedCell(isSelected: true)
        }
        else {
            cell.onSelectedCell(isSelected: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(arrSelectedIndex.contains(indexPath.row)) {
            
            for (index, element) in self.arrSelectedIndex.enumerated() {
                if(element == indexPath.row) {
                    arrSelectedIndex.remove(at: index)
                    let cell = collectionView.cellForItem(at: indexPath) as! SelectAssetCellK
                    cell.onSelectedCell(isSelected: false)
                }
            }
        }
        else {
            arrSelectedIndex.append(indexPath.row)
            let cell = collectionView.cellForItem(at: indexPath) as! SelectAssetCellK
            cell.onSelectedCell(isSelected: true)
        }
        
        
        self.sendAttachmentButton.isHidden = arrSelectedIndex.count == 0 ? true : false
    }
}

extension SelectAssetsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsInRow: CGFloat = 3
        let width = (UIScreen.main.bounds.width)/itemsInRow - SelectAssetsConstant.minimumSpacing * (itemsInRow - 1)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return SelectAssetsConstant.minimumSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SelectAssetsConstant.minimumSpacing
    }
}
