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

package enum AdaptyCustomImageAsset {
    case file(url: URL)
    case remote(url: URL, preview: UIImage?)
    case image(value: UIImage)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package protocol AdaptyImageAssetResolver: Sendable {
    func image(for name: String) -> AdaptyCustomImageAsset?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension AdaptyImageAssetResolver {
    func uiImage(for name: String) -> UIImage? {
        guard let asset = image(for: name) else { return nil }
        
        switch asset {
        case let .file(url):
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                return image
            } else {
                return nil
            }
        case .remote:
            return nil
        case let .image(value):
            return value
        }
    }
}

@MainActor
package struct AdaptyUIDefaultImageResolver: AdaptyImageAssetResolver {
    package init() {}

    package func image(for name: String) -> AdaptyCustomImageAsset? {
        guard let image = UIImage(named: name) else { return nil }
        return .image(value: image)
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
