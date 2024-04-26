//
//  AdaptyUI+TagResolver.swift
//
//
//  Created by Alexey Goncharov on 19.12.23.
//

import Foundation

@available(iOS 13.0, *)
public protocol AdaptyTagResolver {
    func replacement(for tag: String) -> String?
}

@available(iOS 13.0, *)
extension Dictionary<String, String>: AdaptyTagResolver {
    public func replacement(for tag: String) -> String? { self[tag] }
}
