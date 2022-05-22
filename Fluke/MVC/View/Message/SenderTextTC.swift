//
//  SenderTextTC.swift
//  Fluke
//
//  Created by JP on 13/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class SenderTextTC: UITableViewCell {

    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ivImage.layer.cornerRadius = self.ivImage.frame.size.width/2
    }

}
