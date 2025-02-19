//
//  CustomAsset.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package protocol CustomAsset: Sendable {
    var customId: String? { get }
}
