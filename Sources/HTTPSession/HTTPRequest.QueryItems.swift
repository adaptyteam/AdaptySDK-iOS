//
//  HTTPRequest.QueryItems.swift
//  Adapty
//
//  Created by Aleksei Valiano on 11.09.2022.
//

import Foundation

extension HTTPRequest {
    typealias QueryItems = [URLQueryItem]
}

extension URLQueryItem {
    init(name: String, value: CustomStringConvertible?) {
        guard let value = value else {
            self.init(name: name, value: nil)
            return
        }

        self.init(name: name, value: value.description)
    }

    init<T: CustomStringConvertible>(name: String, values: [T]?) {
        guard let array = values, !array.isEmpty else {
            self.init(name: name, value: nil)
            return
        }

        self.init(name: name, value: (array as? [String] ?? array.map { $0.description }).joined(separator: ","))
    }
}

extension Array where Element == HTTPRequest.QueryItems.Element {
    func notNil() -> Self {
        filter { $0.value != nil }
    }

    func emptyToNil() -> Self? {
        isEmpty ? nil : self
    }

    init<T: CustomStringConvertible>(key: String, array: [T]?) {
        guard let array = array else {
            self = []
            return
        }

        self = (array as? [String] ?? array.map { $0.description }).map { Element(name: "\(key)[]", value: $0) }
    }
}
