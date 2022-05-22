//
//  TabbarVC.swift
//  Fluke
//
//  Created by JP on 10/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class ProminentTabBar: UITabBar {
    
    var prominentButtonCallback: (()->())?
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//
//        guard let items = items, items.count>0 else {
//            return super.hitTest(point, with: event)
//        }
//
//        let middleItem = items[items.count/2]
//        let middleExtra = middleItem.imageInsets.top
//        let middleWidth = bounds.width/CGFloat(items.count)
//        let middleRect = CGRect(x: (bounds.width-middleWidth)/2, y: middleExtra, width: middleWidth, height: abs(middleExtra))
//
//        if middleRect.contains(point) {//Center tab
//            prominentButtonCallback?()
//            return nil
//        }
//
//        return super.hitTest(point, with: event)
//    }
    
}



class TabbarVC: UITabBarController {

    var viewLine = UIView()
    let viewWidth:CGFloat = 24.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tabWidth = self.view.frame.size.width/5
        viewLine.frame = CGRect(x: (tabWidth-viewWidth)/2, y: 0, width: 24, height: 2)
        viewLine.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.2431372549, blue: 0.568627451, alpha: 1)
        viewLine.isHidden = true
        self.tabBar.addSubview(viewLine)
        
        
        if #available(iOS 13, *) {
            let appearance = self.tabBar.standardAppearance.copy()
            appearance.backgroundImage = UIImage()
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            self.tabBar.standardAppearance = appearance
        } else {
            self.tabBar.backgroundImage = UIImage()
            self.tabBar.shadowImage = UIImage()
        }

        self.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.tabBar.layer.shadowRadius = 8
        self.tabBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.tabBar.layer.shadowOpacity = 0.3
        
        let prominentTabBar = self.tabBar as! ProminentTabBar
        prominentTabBar.prominentButtonCallback = prominentTabTaped
    }

    func prominentTabTaped() {
        selectedIndex = (tabBar.items?.count ?? 0)/2
        self.viewLine.isHidden = true
    }

    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
            
            if(self.selectedIndex == 2) {
                self.viewLine.isHidden = true
            }
            else {
                
                let tabWidth = self.view.frame.size.width/5
                let xPos = ((tabWidth-self.viewWidth)/2) + (tabWidth * CGFloat(self.selectedIndex))
                self.viewLine.frame = CGRect(x: xPos, y: 0, width: self.viewWidth, height: 2)
                
                self.viewLine.isHidden = false
            }
        }
        
        
    }
    
}
