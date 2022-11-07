//
//  AdaptyModelsExtensions.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 17.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty

extension ProductDiscount.PaymentMode {
    var title: String {
        switch self {
        case .payAsYouGo:
            return "Pay As You Go"
        case .payUpFront:
            return "Pay Up Front"
        case .freeTrial:
            return "Free Trial"
        case .unknown:
            return "Unknown"
        }
    }
}
