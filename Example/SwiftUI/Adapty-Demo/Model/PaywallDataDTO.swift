//
//  PaywallDTO.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 18.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Foundation

struct PaywallDataDTO: Codable {
    let iconName: String
    let description: String
    let buyButtonText: String
    let backgroundColor: String?
    let textColor: String?
    let buyButtonStyle: ProductBuyButtonStyleDTO?
}

struct ProductBuyButtonStyleDTO: Codable {
    let buttonColor: String
    let buttonTextColor: String
}
