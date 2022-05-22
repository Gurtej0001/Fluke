//
//  CommunityCoinfirmationVC.swift
//  Fluke
//
//  Created by JP on 15/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class CommunityCoinfirmationVC: UIViewController {

    @IBOutlet private weak var viewPopupUI:UIView!
    @IBOutlet private weak var viewMain:UIView!
    @IBOutlet private weak var btnNo:UIButton!
    @IBOutlet private weak var lblCondition:UILabel!
    @IBOutlet private weak var btnAccept:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.showViewWithAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction private func btnYesPressed(_ btnSender: UIButton) {
        
        UserModel.sharedUser.joinCommunity(success: { (userDetails) in
            self.hideViewWithAnimation()
        }) { (strError) in
            self.showAlert(strMsg: strError!)
        }
    }
    
    @IBAction private func btnNoPressed(_ btnSender: UIButton) {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.viewPopupUI.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.view.alpha = 0
            
        }, completion: {
            (value: Bool) in
        })
        
    }
 
    @IBAction private func btnAcceptPressed(_ btnSender: UIButton) {
        
        if(btnSender.tag == 0) {
            btnSender.tag = 1
            btnSender.layer.borderWidth = 0
            btnSender.layer.backgroundColor = #colorLiteral(red: 0.9597017169, green: 0.3549151421, blue: 0.6354215741, alpha: 1)
        }
        else {
            btnSender.tag = 0
            btnSender.layer.borderWidth = 1
            btnSender.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
    }
    
    @objc func handleTermTapped(gesture: UITapGestureRecognizer) {
        let termString = "Agree to these terms and privacy policies" as NSString
        let termRange = termString.range(of: " terms ")
        let policyRange = termString.range(of:" privacy policies")

        let tapLocation = gesture.location(in: lblCondition)
        let index = lblCondition.indexOfAttributedTextCharacterAtPoint(point: tapLocation)

        if checkRange(termRange, contain: index) == true {
            
            let staticVC = storyboard?.instantiateViewController(withIdentifier: "StaticVC") as! StaticVC
            staticVC.strTitle = "Terms & Conditions"
            staticVC.strSlug = "18+"
            self.navigationController?.pushViewController(staticVC, animated: true)
            return
        }

        if checkRange(policyRange, contain: index) {
            let staticVC = storyboard?.instantiateViewController(withIdentifier: "StaticVC") as! StaticVC
            staticVC.strTitle = "Privacy Policy"
            staticVC.strSlug = "18+"
            self.navigationController?.pushViewController(staticVC, animated: true)
            return
        }
    }

    func checkRange(_ range: NSRange, contain index: Int) -> Bool {
        return index > range.location && index < range.location + range.length
    }

    private func setupUI() {
        btnNo.layer.cornerRadius = 8
        btnNo.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        btnNo.layer.borderWidth = 1.0
        
        viewPopupUI.layer.cornerRadius = 8.0
        
        btnAccept.layer.cornerRadius = btnAccept.frame.size.width/2
        btnAccept.layer.borderWidth = 1.0
        btnAccept.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        
        let attributedString = NSMutableAttributedString(string: "Agree to these terms and privacy policies", attributes: [
          .font: UIFont(name: "Poppins-Regular", size: 14.0)!,
          .foregroundColor: #colorLiteral(red: 0.9597017169, green: 0.3549151421, blue: 0.6354215741, alpha: 1)
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor(white: 45.0 / 255.0, alpha: 1.0), range: NSRange(location: 0, length: 15))
        attributedString.addAttribute(.foregroundColor, value: UIColor(white: 45.0 / 255.0, alpha: 1.0), range: NSRange(location: 21, length: 3))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTermTapped))
        lblCondition.addGestureRecognizer(tap)
        lblCondition.isUserInteractionEnabled = true
        
        lblCondition.attributedText = attributedString
        
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
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.viewPopupUI.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.view.alpha = 0
                
            }, completion: {
                (value: Bool) in
            
                let feedListVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedListVC") as! FeedListVC
                self.navigationController?.setViewControllers([feedListVC], animated: false)
            })
            
        }
    }

}

extension UILabel {
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}
