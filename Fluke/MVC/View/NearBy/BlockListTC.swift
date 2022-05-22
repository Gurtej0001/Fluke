//
//  BlockListTC.swift
//  Fluke
//
//  Created by JP on 10/08/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class BlockListTC: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var btnBlock: UIButton!
    
    override func awakeFromNib() {
        
        ivImage.layer.cornerRadius = ivImage.frame.size.width/2
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            let shadowSize : CGFloat = 5.0
            let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                       y: -shadowSize / 2,
                                                       width: self.ivImage.frame.size.width + shadowSize,
                                                       height: self.ivImage.frame.size.height + shadowSize))
            self.ivImage.layer.masksToBounds = true
            self.ivImage.layer.shadowColor = #colorLiteral(red: 0.9921568627, green: 0.2470588235, blue: 0.5843137255, alpha: 0.14)
            self.ivImage.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.ivImage.layer.shadowOpacity = 0.5
            self.ivImage.layer.shadowPath = shadowPath.cgPath

        }
        
    }
}
