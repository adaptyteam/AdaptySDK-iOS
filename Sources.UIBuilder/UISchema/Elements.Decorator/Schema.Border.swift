//
//  Schema.Border.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.12.2025.
//

import Foundation

extension Schema {
    typealias Border = VC.Border
}

extension VC.Border {
    static let `default` = Self(
        filling: .same(.solidColor(.transparent)),
        thickness: 1.0
    )
}
