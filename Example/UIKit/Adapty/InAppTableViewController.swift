//
//  InAppTableViewController.swift
//  Adapty_Example
//
//  Created by Andrey Kyashkin on 23/12/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import UIKit
import Adapty

class InAppTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var paywallToShow: PaywallModel?
    private var products: [ProductModel] {
        return paywallToShow?.products ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = paywallToShow?.id
        tableView.tableFooterView = UIView(frame: .zero)
        
        if let paywallToShow = paywallToShow {
            Adapty.logShowPaywall(paywallToShow)
        }
    }
    
}

extension InAppTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(InAppTableViewCell.self)", for: indexPath) as? InAppTableViewCell else {
            return UITableViewCell()
        }
        
        cell.product = products[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
}

extension InAppTableViewController: InAppTableViewCellDelegate {
    
    func didBuyProduct(_ product: ProductModel, useDiscount: Bool) {
        let discountId: String? = useDiscount ? product.discounts.first?.identifier : nil
        
        setUI(enabled: false)
        Adapty.makePurchase(product: product, offerId: discountId) { (purchaserInfo, receipt, response, product, error) in
            self.setUI(enabled: true)
            
            guard error == nil else {
                self.showAlert(for: error)
                return
            }
            
            print("receipt: \(receipt ?? ""), response: \(response ?? [:])")
        }
    }
    
}
