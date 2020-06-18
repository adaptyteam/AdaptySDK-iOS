//
//  InAppTableViewCell.swift
//  Adapty_Example
//
//  Created by Andrey Kyashkin on 23/12/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import UIKit
import Adapty

protocol InAppTableViewCellDelegate: class {
    func didBuyProduct(_ product: ProductModel, useDiscount: Bool)
}

class InAppTableViewCell: UITableViewCell {
    
    weak var delegate: InAppTableViewCellDelegate?
    var product: ProductModel? {
        didSet {
            titleLabel.text = "\(product?.localizedTitle ?? "[Missing title in AppStore connect]") for \(product?.localizedPrice ?? "[Missing price]")"
            
            if product?.discounts.count != 0 {
                discountLabel.text = "Use discount"
                discountSwitch.isEnabled = true
            } else {
                discountLabel.text = "No discounts"
                discountSwitch.isEnabled = false
            }
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var discountSwitch: UISwitch!
    
    @IBAction func buyButtonAction(_ sender: Any) {
        guard let product = product else {
            return
        }
        
        delegate?.didBuyProduct(product, useDiscount: discountSwitch.isOn)
    }
    
}
