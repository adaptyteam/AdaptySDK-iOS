//
//  MainControllerCells.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 16.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import UIKit

class MainControllerDefaultCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    func update(title: String?, subtitle: String?) {
        titleLabel.text = title
        titleLabel.isHidden = title?.isEmpty ?? true
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle?.isEmpty ?? true
    }
}

class MainControllerActionCell: UITableViewCell {
    enum Style {
        case `default`
        case destructive
    }

    @IBOutlet var titleLabel: UILabel!
    
    func update(title: String, style: Style) {
        titleLabel.text = title
        
        switch style {
        case .default:
            titleLabel.textColor = .systemBlue
        case .destructive:
            titleLabel.textColor = .systemRed
        }
    }
}

class MainControllerTextFieldCell: UITableViewCell {
    @IBOutlet var textFiled: UITextField!
    @IBOutlet var actionButton: UIButton!
    
    private var action: ((String?) -> Void)?
    
    func update(action: @escaping (String?) -> Void) {
        self.action = action
    }
    
    @IBAction func actionButtonPressed() {
        action?(textFiled.text)
    }
}
