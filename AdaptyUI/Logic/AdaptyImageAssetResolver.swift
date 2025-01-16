//
//  AdaptyAssetResolver.swift
//  Adapty
//
//  Created by Alexey Goncharov on 1/16/25.
//

#if canImport(UIKit)

import Adapty
import SwiftUI
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public protocol AdaptyImageAssetResolver: Sendable {
    func image(for name: String) -> UIImage?
}

@MainActor
package struct AdaptyUIDefaultImageResolver: AdaptyImageAssetResolver {
    package init() {}

    package func image(for name: String) -> UIImage? {
        UIImage(named: name)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptyImageAssetViewModel: ObservableObject {
    let assetResolver: AdaptyImageAssetResolver

    package init(
        assetResolver: AdaptyImageAssetResolver
    ) {
        self.assetResolver = assetResolver
    }
}

#endif
