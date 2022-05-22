//
//  ChatOutgoingCell.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatOutgoingCell: ChatCell {
    
    @IBOutlet weak var statusImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleImageView.roundCorners(radius: 8, isIncoming: false)
        bubbleImageView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        bubbleImageView.layer.applyShadow(color: #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1), alpha: 0.4, y: 12.0, blur: 12.0)
    }
    
    override class func layoutModel() -> ChatCellLayoutModel {
        let containerInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 12.0, right: 14.0)
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.avatarSize = .zero
        defaultLayoutModel.containerInsets = containerInsets
        defaultLayoutModel.timeLabelHeight = 15.0
        defaultLayoutModel.spaceBetweenTopLabelAndTextView = 12.0
        
        return defaultLayoutModel
    }
    
    func setupStatusImage(_ image: UIImage) {
        statusImageView.image = image
    }
}
