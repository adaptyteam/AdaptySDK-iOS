//
//  InAppTableViewController.swift
//  Adapty_Example
//
//  Created by Andrey Kyashkin on 23/12/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Adapty

class InAppTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var containerToShow: PurchaseContainerModel?
    private var products: [ProductModel] {
        return containerToShow?.products ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = containerToShow?.developerId
        tableView.tableFooterView = UIView(frame: .zero)
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
        let skProduct = product.skProduct
        var discountsIds: [String]?
        if #available(iOS 12.2, *), useDiscount {
            discountsIds = skProduct?.discounts.map({ $0.identifier ?? "" })
        }
        
        setUI(enabled: false)
        Adapty.makePurchase(product: product, offerId: discountsIds?.first) { (receipt, response, error) in
            self.setUI(enabled: true)
            
            guard error == nil else {
                self.showAlert(for: error)
                return
            }
            
            print("receipt: \(receipt ?? ""), response: \(response ?? [:])")
        }
    }
    
}
