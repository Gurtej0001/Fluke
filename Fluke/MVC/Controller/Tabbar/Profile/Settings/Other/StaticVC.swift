//
//  StaticVC.swift
//  Fluke
//
//  Created by JP on 05/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import WebKit

class StaticVC: UIViewController {
    
    @IBOutlet weak private var webView: WKWebView!
    var strTitle: String!
    var strSlug: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadURL()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func loadURL() {
        
        UserModel.sharedUser.getContetForSlug(strSlug: strSlug, success: { (strResponse) in
            
            DispatchQueue.main.async {
                self.webView.loadHTMLString(strResponse, baseURL: nil)
            }
            
        }) { (strError) in
            self.showAlertWithBackController(strMsg: strError!)
        }
        
        self.title = strTitle
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}
