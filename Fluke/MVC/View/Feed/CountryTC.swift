//
//  CountryTC.swift
//  Fluke
//
//  Created by JP on 18/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class CountryTC: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ivImageSelection: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
