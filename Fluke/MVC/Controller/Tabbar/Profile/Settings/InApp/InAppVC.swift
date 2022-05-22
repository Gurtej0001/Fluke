//
//  InAppVC.swift
//  Fluke
//
//  Created by JP on 07/06/20.
//  Copyright © 2020 JP. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD

class InAppCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblAmountSymbol: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var btnBuy: UIButton!
    
    override func awakeFromNib() {
        
        self.btnBuy.layer.cornerRadius = 8
        
        self.viewBg.layer.cornerRadius = 8
        self.viewBg.layer.borderWidth = 1
    }
}


class InAppVC: UIViewController {
    
    @IBOutlet private weak var tblList: UITableView!
    
    private var productsRequest = SKProductsRequest()
    private var iapProducts = [SKProduct]()
    private var arrColor = [UIColor]()
    private var arrIdentifire = [String]()
    private var numberFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchAvailableProducts()
        arrColor = [#colorLiteral(red: 0.3215686275, green: 0.8549019608, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0.7450980392, green: 0.7411764706, blue: 0.9882352941, alpha: 1), #colorLiteral(red: 0.9411764706, green: 0.8431372549, blue: 0.3176470588, alpha: 1)]
        arrIdentifire = ["com.FlukeK.app.oneMonth", "com.FlukeK.app.threeMontha", "com.FlukeK.app.sixMontha"]
    }
    
    private func setupUI() {
        
        self.numberFormatter.formatterBehavior = .behavior10_4
        self.numberFormatter.numberStyle = .currency
        
        self.tblList.tableFooterView = UIView()
        self.tblList.rowHeight = UITableView.automaticDimension
        self.tblList.estimatedRowHeight = 44.0
    }
    
    private func fetchAvailableProducts() {
        
        let productIdentifiers = NSSet(objects: "com.FlukeK.app.oneMonth", "com.FlukeK.app.threeMontha", "com.FlukeK.app.sixMontha")
        
        guard let identifier = productIdentifiers as? Set<String> else { return }
        productsRequest = SKProductsRequest(productIdentifiers: identifier)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    private func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    private func purchaseProduct(product: SKProduct) {
        
        if self.canMakePurchases() {
            SVProgressHUD.show(withStatus: "Purchasing...")
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            print("Product to Purchase: \(product.productIdentifier)")
        }
        else{
            self.showAlert(strMsg: "Purchases are disabled in your device!")
        }
    }
    
    @IBAction private func btnBack(_btnSender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRestoreOnClick(_btnSender: UIBarButtonItem) {
        SVProgressHUD.show(withStatus: "Restoring...")
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @IBAction func btnBuyNow(_ sender: UIButton) {
        self.purchaseProduct(product: iapProducts[sender.tag])
    }
}

extension InAppVC: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        SVProgressHUD.dismiss()
        self.showAlert(strMsg: "You've successfully restored your purchase!")
    }
    
    private func getDetailsFor(response: SKProductsResponse, strId: String) -> SKProduct? {
        
        for details in response.products {
            
            if(details.productIdentifier == strId) {
                return details
            }
            
        }
        
        return nil
        
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            
            iapProducts.append(self.getDetailsFor(response: response, strId: arrIdentifire[0])!)
            iapProducts.append(self.getDetailsFor(response: response, strId: arrIdentifire[1])!)
            iapProducts.append(self.getDetailsFor(response: response, strId: arrIdentifire[2])!)
            
            DispatchQueue.main.async {
                self.tblList.reloadData()
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    SVProgressHUD.dismiss()
                    
                    if let paymentTransaction = transaction as? SKPaymentTransaction {
                        SKPaymentQueue.default().finishTransaction(paymentTransaction)
                    }
                    self.showAlert(strMsg: "You've successfully purchased")
                    
                    UserModel.sharedUser.purchasePlan(success: { (strMsg) in
                        UserModel.sharedUser.strPlanId = "1"
                    }) { (strError) in
                        
                    }
                                        
                case .failed:
                    SVProgressHUD.dismiss()
                    if trans.error != nil {
                        self.showAlert(strMsg: trans.error!.localizedDescription)
                        print(trans.error!)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                case .restored:
                    print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default: break
                }
            }
        }
    }
}

extension InAppVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iapProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.numberFormatter.locale = iapProducts[indexPath.row].priceLocale
        let price = "\(iapProducts[indexPath.row].price)"
        
        let cell: InAppCell = tableView.dequeueReusableCell(withIdentifier: "InAppCell") as! InAppCell
        cell.lblTitle.text = iapProducts[indexPath.row].localizedDescription
        cell.viewBg.layer.borderColor = arrColor[indexPath.row].cgColor
        cell.btnBuy.tag = indexPath.row
        
        cell.lblAmount.text = price
        cell.lblAmountSymbol.text = self.numberFormatter.currencySymbol
        
        cell.btnBuy.backgroundColor = arrColor[indexPath.row]
        cell.btnBuy.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        
        
        
        if(indexPath.row == 0) {
            cell.ivImage.image = #imageLiteral(resourceName: "oneMonth")
        }
        else if(indexPath.row == 1) {
            cell.ivImage.image = #imageLiteral(resourceName: "threeMonth")
        }
        else {
            cell.ivImage.image = #imageLiteral(resourceName: "sixMonth")
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
