//
//  AdaptyTagResolverViewModel.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, *)
public protocol AdaptyTagResolver {
    func replacement(for tag: String) -> String?
}

@available(iOS 15.0, *)
extension Dictionary<String, String>: AdaptyTagResolver {
    public func replacement(for tag: String) -> String? { self[tag] }
}

@available(iOS 15.0, *)
class AdaptyTagResolverViewModel: ObservableObject, AdaptyTagResolver {
    let tagResolver: AdaptyTagResolver?
    
    init(tagResolver: AdaptyTagResolver?) {
        self.tagResolver = tagResolver
    }
    
    func replacement(for tag: String) -> String? {
        tagResolver?.replacement(for: tag)
    }
}

#endif
