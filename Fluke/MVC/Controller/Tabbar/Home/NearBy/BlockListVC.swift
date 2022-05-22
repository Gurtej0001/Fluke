//
//  BlockListVC.swift
//  Fluke
//
//  Created by JP on 10/08/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit

class BlockListVC: UIViewController {

    @IBOutlet weak private var tblList: UITableView!
    
    private var isLoadingAPIList : Bool = false
    private var arrList = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblList.tableFooterView = UIView()
        self.getAllList(strPage: "1")
    }

    @IBAction private func btnBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnBlock(_ sender: UIButton) {
        self.view.endEditing(true)
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: appName, message: "Are you sure you want to unblock \(self.arrList[sender.tag].getDisplayName())?", preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                
                self.arrList[sender.tag].unblockUser(strId: self.arrList[sender.tag].strBlockedID, success: { (msg) in
                    
                    DispatchQueue.main.async {
                        self.arrList.remove(at: sender.tag)
                        self.tblList.reloadData()
                    }
                    
                }) { (strError) in
                    self.showAlert(strMsg: strError!)
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func getAllList(strPage: String) {
        
        UserModel.sharedUser.getListOfBlockedUser(strPage: strPage, success: { (arrResponse) in
            
            DispatchQueue.main.async {
                self.isLoadingAPIList = false
                
                if(strPage == "1") {
                    self.arrList = arrResponse
                }
                else {
                    self.arrList.append(contentsOf: arrResponse)
                }
                
                self.tblList.reloadData()
            }
            
        }) { (strError) in
            self.isLoadingAPIList = false
            self.showAlert(strMsg: strError!)
        }
    }
    
}


extension BlockListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: BlockListTC = tableView.dequeueReusableCell(withIdentifier: "BlockListTC") as! BlockListTC
        cell.btnBlock.tag = indexPath.row
        cell.lblName.text = arrList[indexPath.row].getDisplayName()
        setImagefromURL(ivImage: cell.ivImage, strUrl: arrList[indexPath.row].strProfileImage)
        return cell
        
    }
    
}

extension BlockListVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingAPIList){
            
            let record = self.arrList.last
            
            if(record?.strTotalPage != record?.strCurrentPage) {
                self.isLoadingAPIList = true
                let newPage = Int(record!.strCurrentPage)! + 1
                self.getAllList(strPage: "\(newPage)")
            }
        }
    }
}
