//
//  CallTC.swift
//  Fluke
//
//  Created by JP on 10/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class CallTC: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var ivCallTypeImage: UIImageView!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        ivImage.layer.cornerRadius = ivImage.frame.size.width/2
        ivImage.layer.borderWidth = 0.5
        ivImage.layer.borderColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
    }

}
