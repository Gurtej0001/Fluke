//
//  MessageTabVC.swift
//  Fluke
//
//  Created by JP on 10/03/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class MessageTabVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    @IBOutlet var btnCallLogs: UIButton!
    @IBOutlet var btnChatMsg: UIButton!
        
    var pcController: UIPageViewController!
    var arrVC:[UIViewController] = []
    var currentPage: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPage = 0
        createPageViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Custom Methods
    
    func selectedButton(btn: UIButton) {
        btn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
    }
    
    func unSelectedButton(btn: UIButton) {
        btn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4), for: .normal)
    }
    
    //MARK: - IBaction Methods

    @IBAction func btnOptionClicked(btn: UIButton) {
        
        pcController.setViewControllers([arrVC[btn.tag-1]], direction: .reverse, animated: false, completion: {(Bool) -> Void in
        })
        
        resetTabBarForTag(tag: btn.tag-1)
    }
    
    //MARK: - CreatePagination
    
    func createPageViewController() {
        
        pcController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        pcController.view.backgroundColor = UIColor.clear
        pcController.delegate = self
        pcController.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pcController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        let callLogVC = storyboard?.instantiateViewController(withIdentifier: "CallLogVC") as! CallLogVC
        
        let story = UIStoryboard.init(name: "Dialogs", bundle: nil)
        let chatMsgVC = story.instantiateViewController(withIdentifier: "DialogsViewController") as! DialogsViewController
        
        arrVC = [callLogVC, chatMsgVC]
        
        pcController.setViewControllers([callLogVC], direction: .forward, animated: false, completion: nil)
        
        self.addChild(pcController)
        self.view.addSubview(pcController.view)
        pcController.didMove(toParent: self)
    }
    
    
    func indexofviewController(viewCOntroller: UIViewController) -> Int {
        if(arrVC .contains(viewCOntroller)) {
            return arrVC.index(of: viewCOntroller)!
        }
        
        return -1
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = indexofviewController(viewCOntroller: viewController)
        
        if(index != -1) {
            index = index - 1
        }
        
        if(index < 0) {
            return nil
        }
        else {
            return arrVC[index]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = indexofviewController(viewCOntroller: viewController)
        
        if(index != -1) {
            index = index + 1
        }
        
        if(index >= arrVC.count) {
            return nil
        }
        else {
            return arrVC[index]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if(completed) {
            currentPage = arrVC.index(of: (pcController.viewControllers?.last)!)!
            resetTabBarForTag(tag: currentPage)
        }
    }
    
    func resetTabBarForTag(tag: Int) {
        
        var sender: UIButton!
        
        if(tag == 0) {
            sender = btnCallLogs
        }
        else if(tag == 1) {
            sender = btnChatMsg
        }
        
        currentPage = tag
        unSelectedButton(btn: btnCallLogs)
        unSelectedButton(btn: btnChatMsg)
        selectedButton(btn: sender)
    }
    
}

