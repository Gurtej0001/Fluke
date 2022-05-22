//
//  ReportFeed.swift
//  Fluke
//
//  Created by Ketan on 13/01/21.
//  Copyright © 2021 Ketan Patel. All rights reserved.
//

import UIKit


class ReportFeed: UIViewController, UITextViewDelegate {
    
    @IBOutlet private weak var viewReason:UIView!
    @IBOutlet private weak var lblReason:UILabel!
    @IBOutlet private weak var tvText:UITextView!
    
    var feedDetails:FeedModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupUI() {
        viewReason.layer.cornerRadius = 4.0
        viewReason.layer.borderColor = UIColor.lightGray.cgColor
        viewReason.layer.borderWidth = 0.5
        
        tvText.layer.cornerRadius = 4.0
        tvText.layer.borderColor = UIColor.lightGray.cgColor
        tvText.layer.borderWidth = 0.5
    }
        
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSelectReason(_btnSender: UIButton) {
        
        RPicker.selectOption(title: "Select Reason", cancelText: "Cancel", doneText: "Done", dataArray: ["Privacy concerns", "Content is not relevant", "Sexually explicit/strongly suggestive", "Profane or obscene content", "Copyright or other legal issues", "Illegal activity", "Hate speech", "Other"], selectedIndex: 0) { (str, index) in
            self.lblReason.text = str
        }
    }
    
    @IBAction func btnSubmit(_btnSender: UIButton) {
        
        if(tvText.text == "") {
            self.showAlert(strMsg: "Enter description")
        }
        else {
            DispatchQueue.main.async {
                
                self.feedDetails.reportFeed(reason: self.lblReason.text!, description: self.tvText.text!, success: { (response) in
                    self.showAlertWithBackController(strMsg: "Thank you, we received your report and we will act accordingly")
                    
                }) { (strError) in
                    self.showAlert(strMsg: strError!)
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
        
    }
    
}
