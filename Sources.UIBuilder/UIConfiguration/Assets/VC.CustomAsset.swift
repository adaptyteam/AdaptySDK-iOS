//
//  VC.CustomAsset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package protocol VCCustomAsset: Sendable, Hashable {
    var customId: String? { get }
}

extension VC {
    typealias CustomAsset = VCCustomAsset
}
