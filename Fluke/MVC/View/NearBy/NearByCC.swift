//
//  NearByCC.swift
//  Fluke
//
//  Created by JP on 28/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class NearByCC: UICollectionViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var ivBadge: UIImageView!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var viewLayer: UIView!
    
    override func awakeFromNib() {
        
        self.viewLayer.layer.cornerRadius = 8
        ivImage.layer.cornerRadius = ivImage.frame.size.width/2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            let shadowSize : CGFloat = 5.0
            let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                       y: -shadowSize / 2,
                                                       width: self.viewLayer.frame.size.width + shadowSize,
                                                       height: self.viewLayer.frame.size.height + shadowSize))
            self.viewLayer.layer.masksToBounds = false
            self.viewLayer.layer.shadowColor = #colorLiteral(red: 0.9921568627, green: 0.2470588235, blue: 0.5843137255, alpha: 0.14)
            self.viewLayer.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.viewLayer.layer.shadowOpacity = 0.5
            self.viewLayer.layer.shadowPath = shadowPath.cgPath

        }
        
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
