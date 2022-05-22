//
//  SettingsVC.swift
//  Fluke
//
//  Created by JP on 15/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class SettingsTC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivImageLogo: UIImageView!
    @IBOutlet weak var ivNextArrow: UIImageView!
    @IBOutlet weak var swSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}


class VerifyListTC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivImageLogo: UIImageView!
    @IBOutlet weak var ivBagdge: UIImageView!
    @IBOutlet weak var viewBg: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewBg.layer.cornerRadius = 4
        self.viewBg.layer.borderColor = #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 0.1).cgColor
        self.viewBg.layer.borderWidth = 1
    }

}
