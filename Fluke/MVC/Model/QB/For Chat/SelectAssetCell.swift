//
//  SelectAssetCell.swift
//  sample-chat-swift
//
//  Created by Injoit on 12/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class SelectAssetCellK: UICollectionViewCell {
    
    @IBOutlet weak var durationVideoLabel: UILabel!
    @IBOutlet weak var videoTypeView: UIView!
    @IBOutlet weak var assetTypeImageView: UIImageView!
    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var ivSelectedImage: UIImageView!
    
    //MARK: - Overrides
    override func awakeFromNib() {
        videoTypeView.setRoundView(cornerRadius: 3)
        videoTypeView.isHidden = true
        assetImageView.contentMode = .scaleAspectFill
    }
    
    override func prepareForReuse() {
        assetTypeImageView.image = nil
        videoTypeView.setRoundView(cornerRadius: 3)
        videoTypeView.isHidden = true
    }
    
    func onSelectedCell(isSelected: Bool) {
        
        if isSelected == true {
            ivSelectedImage.isHidden = false
        } else {
            ivSelectedImage.isHidden = true
        }
    }
}


