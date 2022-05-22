//
//  CongratulationVC.swift
//  Fluke
//
//  Created by JP on 25/02/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class CongratulationVC: UIViewController {

    @IBOutlet weak private var btnExplore: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setExploreButton()
    }

    private func setExploreButton() {
        btnExplore.layer.cornerRadius = 8.0
    }
    
    @IBAction private func btnExploreNowClicked(_ btnSender: UIButton) {
        self.view.endEditing(true)
        
        let tabbarVC = storyboard?.instantiateViewController(withIdentifier: "TabbarVC") as! TabbarVC
        tabbarVC.selectedIndex = 2
        self.navigationController?.pushViewController(tabbarVC, animated: true)
    }
    
}
