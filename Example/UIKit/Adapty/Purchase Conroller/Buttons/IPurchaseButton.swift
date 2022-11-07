//
//  IPurchaseButton.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 17.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Foundation
import Adapty

protocol IPurchaseButton: UIView {
    func update(product: PaywallProduct, config: PurchaseConfiguration, action: @escaping () -> Void)
}
