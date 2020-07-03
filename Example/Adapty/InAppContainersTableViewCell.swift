//
//  InAppContainersTableViewCell.swift
//  Adapty_Example
//
//  Created by Andrey Kyashkin on 09/06/2020.
//  Copyright © 2020 Adapty. All rights reserved.
//

import UIKit
import Adapty

protocol InAppContainersTableViewCellDelegate: class {
    func didShowPaywall(for container: PurchaseContainerModel)
}

class InAppContainersTableViewCell: UITableViewCell {

    weak var delegate: InAppContainersTableViewCellDelegate?
    var container: PurchaseContainerModel? {
        didSet {
            titleLabel.text = container?.developerId
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func showPaywallButtonAction(_ sender: Any) {
        guard let container = container else {
            return
        }
        
        delegate?.didShowPaywall(for: container)
    }
    

}
