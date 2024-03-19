//
//  HTTPMethod.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 21.09.2022.
//

import Foundation

enum HTTPMethod: String, ExpressibleByStringLiteral, Sendable, Equatable {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"

    init(stringLiteral value: String) {
        self = HTTPMethod(rawValue: value.uppercased()) ?? .get
    }
}

extension HTTPMethod: CustomStringConvertible {
    var description: String { rawValue }
}
