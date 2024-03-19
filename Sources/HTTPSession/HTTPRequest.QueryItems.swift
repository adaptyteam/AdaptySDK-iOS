//
//  HTTPRequest.QueryItems.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.09.2022.
//

import Foundation

extension HTTPRequest {
    typealias QueryItems = [URLQueryItem]
}

extension URLQueryItem {
    init(name: String, value: CustomStringConvertible?) {
        guard let value else {
            self.init(name: name, value: nil)
            return
        }

        self.init(name: name, value: value.description)
    }

    init(name: String, values: [some CustomStringConvertible]?) {
        guard let array = values, !array.isEmpty else {
            self.init(name: name, value: nil)
            return
        }

        self.init(name: name, value: (array as? [String] ?? array.map { $0.description }).joined(separator: ","))
    }
}

extension [HTTPRequest.QueryItems.Element] {
    func notNil() -> Self {
        filter { $0.value != nil }
    }

    func emptyToNil() -> Self? {
        isEmpty ? nil : self
    }

    init(key: String, array: [some CustomStringConvertible]?) {
        guard let array else {
            self = []
            return
        }

        self = (array as? [String] ?? array.map { $0.description }).map { Element(name: "\(key)[]", value: $0) }
    }
}
