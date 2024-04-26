//
//  AdaptyUI+TagResolver.swift
//
//
//  Created by Alexey Goncharov on 19.12.23.
//

import Foundation

public protocol AdaptyTagResolver {
    func replacement(for tag: String) -> String?
}

extension Dictionary<String, String>: AdaptyTagResolver {
    public func replacement(for tag: String) -> String? { self[tag] }
}
