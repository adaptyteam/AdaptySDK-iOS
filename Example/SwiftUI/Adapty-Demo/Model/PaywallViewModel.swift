//
//  PaywallViewModel.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Foundation
import SwiftUI

struct PaywallViewModel: Equatable {
    let iconName: String
    let description: String
    let buyActionTitle: String
    let restoreActionTitle: String
    let productModels: [ProductItemModel]
    let backgroundColor: Color
    let textColor: Color
    let buyButtonStyle: ProductBuyButtonStyle
}

struct ProductItemModel: Equatable {
    let id: String
    let priceString: String
    let period: String
}

struct ProductBuyButtonStyle: Equatable {
    let buttonColor: Color
    let buttonTextColor: Color
}
