//
//  InAppContainersTableViewCell.swift
//  Adapty_Example
//
//  Created by Andrey Kyashkin on 09/06/2020.
//  Copyright © 2020 Adapty. All rights reserved.
//

import UIKit
import Adapty

protocol InAppContainersTableViewCellDelegate: AnyObject {
    func didShowRemotePaywall(for paywall: PaywallModel)
}

class InAppContainersTableViewCell: UITableViewCell {

    weak var delegate: InAppContainersTableViewCellDelegate?
    var paywall: PaywallModel? {
        didSet {
            titleLabel.text = paywall?.developerId
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBAction private func showRemotePaywallButtonAction(_ sender: Any) {
        guard let paywall = paywall else {
            return
        }
        
        delegate?.didShowRemotePaywall(for: paywall)
    }
}
