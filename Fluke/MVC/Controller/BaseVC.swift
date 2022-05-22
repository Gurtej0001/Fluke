//
//  BaseVC.swift
//  Fluke
//
//  Created by JP on 25/02/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

extension UIViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//        if (text == "\n") {
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
    
    func showAlert(strMsg: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: appName, message: strMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertWithBackController(strMsg: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: appName, message: strMsg, preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertWithBackToRootController(strMsg: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: appName, message: strMsg, preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertWithForceUpdate(strMsg: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constant.NewVerions(), message: strMsg, preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                
                self.showAlertWithForceUpdate(strMsg: strMsg)
                
                let urlStr = "itms-apps://itunes.apple.com/app/apple-store/id375380948?mt=8"
                
                 if #available(iOS 10.0, *) {
                     UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)

                 } else {
                     UIApplication.shared.openURL(URL(string: urlStr)!)
                 }

            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
