//
//  CountrySelectionVC.swift
//  Fluke
//
//  Created by JP on 18/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

protocol CountrySelectionDelegate: class {
    func selectedCountry(_ strCountry: String?)
}

class CountrySelectionVC: UIViewController {
    
    @IBOutlet private weak var viewPopupUI:UIView!
    @IBOutlet private weak var viewMain:UIView!
    @IBOutlet private weak var viewSearch:UIView!
    @IBOutlet private weak var btnCancel:UIButton!
    @IBOutlet private weak var btnSelect:UIButton!
    
    @IBOutlet private weak var tblList:UITableView!
    
    weak var delegate: CountrySelectionDelegate?
    
    private var strSelectedCountry = ""
    
    private var selectedIndex = 0
    var arrCountry:[String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.showViewWithAnimation()
        
        self.strSelectedCountry = arrCountry[0]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction private func btnSelectPressed(_ btnSender: UIButton) {
        delegate?.selectedCountry(strSelectedCountry)
        self.hideViewWithAnimation()
    }
    
    @IBAction private func btnCancelPressed(_ btnSender: UIButton) {
        self.hideViewWithAnimation()
    }
    
    private func setupUI() {
        btnCancel.layer.cornerRadius = 8
        btnCancel.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        btnCancel.layer.borderWidth = 1.0
        
        viewSearch.layer.cornerRadius = 8
        
        viewPopupUI.layer.cornerRadius = 8.0
    }
        
    //MARK: - Animation Method
    
    private func showViewWithAnimation() {
        
        self.view.alpha = 0
        self.viewPopupUI.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.3) {
            self.viewPopupUI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1
        }
        
    }
    
    private func hideViewWithAnimation() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.viewPopupUI.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.view.alpha = 0
            
        }, completion: {
            (value: Bool) in
            self.removeFromParent()
            self.view.removeFromSuperview()
        })
    }
    
}

extension CountrySelectionVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCountry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CountryTC = tableView.dequeueReusableCell(withIdentifier: "CountryTC") as! CountryTC
        
        cell.lblName.text = arrCountry[indexPath.row]
        
        if(indexPath.row == selectedIndex) {
            cell.ivImageSelection.isHidden = false
            cell.lblName.textColor = #colorLiteral(red: 0.9597017169, green: 0.3549151421, blue: 0.6354215741, alpha: 1)
        }
        else {
            cell.ivImageSelection.isHidden = true
            cell.lblName.textColor = #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell: CountryTC = tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? CountryTC {
            cell.ivImageSelection.isHidden = true
            cell.lblName.textColor = #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
        }
        
        selectedIndex = indexPath.row
        
        let cellSelected: CountryTC = tableView.cellForRow(at: indexPath) as! CountryTC
        cellSelected.ivImageSelection.isHidden = false
        cellSelected.lblName.textColor = #colorLiteral(red: 0.9597017169, green: 0.3549151421, blue: 0.6354215741, alpha: 1)
        
        strSelectedCountry = arrCountry[indexPath.row]
    }
    
}
