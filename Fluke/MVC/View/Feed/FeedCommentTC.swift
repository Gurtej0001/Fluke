//
//  FeedCommentTC.swift
//  Fluke
//
//  Created by JP on 05/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class FeedCommentTC: UITableViewCell {

    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivImage.layer.cornerRadius = ivImage.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
