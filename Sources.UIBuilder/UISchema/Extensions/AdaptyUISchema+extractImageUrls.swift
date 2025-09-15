//
//  AdaptyUISchema+ImageUrls.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.03.2024
//

import Foundation

extension AdaptyUISchema {
    func extractImageUrls(forLocalId localeId: LocaleId) -> Set<URL> {
        let assets: [String: Asset] =
        if let localAssets = localization(by: localeId)?.assets {
                localAssets.merging(self.assets, uniquingKeysWith: { current, _ in current })
            } else {
                self.assets
            }

        return Set(assets.values.compactMap {
            switch $0 {
            case let .image(image):
                image.url
            case let .video(video):
                video.image.url
            default:
                nil
            }
        })
    }
}
