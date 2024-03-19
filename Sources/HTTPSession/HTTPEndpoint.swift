//
//  HTTPEndpoint.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2022.
//

import Foundation

struct HTTPEndpoint: Sendable, Equatable {
    typealias Path = String
    let method: HTTPMethod
    let path: Path
}

extension HTTPEndpoint: CustomStringConvertible {
    var description: String { "\(method) \(path)" }
}
