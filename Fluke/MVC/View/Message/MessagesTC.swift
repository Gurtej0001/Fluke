//
//  MessagesTC.swift
//  Fluke
//
//  Created by JP on 10/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class MessagesTC: UITableViewCell {

        @IBOutlet weak var lblName: UILabel!
        @IBOutlet weak var ivImage: UIImageView!
        @IBOutlet weak var viewOnline: UIView!
        @IBOutlet weak var lblCity: UILabel!
        @IBOutlet weak var lblTime: UILabel!
        @IBOutlet weak var lblUnRead: UILabel!
    
        override func awakeFromNib() {
            super.awakeFromNib()
            
            ivImage.layer.cornerRadius = ivImage.frame.size.width/2
            viewOnline.layer.cornerRadius = viewOnline.frame.size.width/2
            lblUnRead.layer.cornerRadius = lblUnRead.frame.size.height/2
        }

    }
