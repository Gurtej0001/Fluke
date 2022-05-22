//
//  FeedPhotosCC.swift
//  Fluke
//
//  Created by JP on 17/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class FeedPhotosCC: UICollectionViewCell {
    
    @IBOutlet private weak var viewLayer: UIView!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    
    override func awakeFromNib() {
        self.viewLayer.layer.cornerRadius = 4
        self.ivImage.layer.cornerRadius = 4
        self.btnDelete.layer.cornerRadius = self.btnDelete.frame.size.width/2
    }
    
}
