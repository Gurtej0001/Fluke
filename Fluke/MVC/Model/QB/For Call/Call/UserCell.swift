//
//  ConferenceUserCell.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

class UserCell: UICollectionViewCell {
    //MARK: - IBOutlets
    @IBOutlet private weak var nameView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    
    //MARK: - Properties
    var videoView: UIView? {
        didSet {
            guard let view = videoView else {
                return
            }
            
            containerView.insertSubview(view, at: 0)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        }
    }
    
    /**
     *  Mute user block action.
     */
    var didPressMuteButton: ((_ isMuted: Bool) -> Void)?
    
    
    let unmutedImage = UIImage(named: "ic-qm-videocall-dynamic-off")!
    let mutedImage = UIImage(named: "ic-qm-videocall-dynamic-on")!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        muteButton.setImage(unmutedImage, for: .normal)
        muteButton.setImage(mutedImage, for: .selected)
        muteButton.isHidden = true
        muteButton.isSelected = false
    }
    
    //MARK: - Actions
    @IBAction func didPressMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        didPressMuteButton?(sender.isSelected)
    }
}
