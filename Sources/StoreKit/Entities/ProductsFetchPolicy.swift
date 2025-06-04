//
//  ProductsFetchPolicy.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import Foundation

enum ProductsFetchPolicy: Sendable, Hashable {
    case `default`
    case returnCacheDataElseLoad
}
