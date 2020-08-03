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
    func didShowPaywall(for paywall: PaywallModel)
}

class InAppContainersTableViewCell: UITableViewCell {

    weak var delegate: InAppContainersTableViewCellDelegate?
    var paywall: PaywallModel? {
        didSet {
            titleLabel.text = paywall?.developerId
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func showPaywallButtonAction(_ sender: Any) {
        guard let paywall = paywall else {
            return
        }
        
        delegate?.didShowPaywall(for: paywall)
    }
    

}
