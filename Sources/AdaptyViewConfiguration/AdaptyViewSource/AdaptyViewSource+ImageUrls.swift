//
//  AdaptyViewSource+ImageUrls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.03.2024
//

import Foundation

extension AdaptyViewSource {
    func extractImageUrls(_ locale: AdaptyLocale) -> Set<URL> {
        let assets: [String: Asset] =
            if let localAssets = getLocalization(locale)?.assets {
                localAssets.merging(self.assets, uniquingKeysWith: { current, _ in current })
            } else {
                self.assets
            }

        return Set(assets.values.compactMap {
            switch $0 {
            case let .image(.url(url, _)):
                url
            case let .video(.url(_, image: .url(imageUrl, previewRaster: _))):
                imageUrl
            default:
                nil
            }
        })
    }
}
