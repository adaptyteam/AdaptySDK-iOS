//
//  ViewConfiguration+extractLocale.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.03.2024
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    public func extractImageUrls(_ locale: String) -> Set<URL> {
        extractImageUrls(AdaptyLocale(id: locale))
    }

    func extractImageUrls(_ locale: AdaptyLocale) -> Set<URL> {
        let assets: [String: AdaptyUI.Asset]

        if let localAssets = getLocalization(locale)?.assets {
            assets = localAssets.merging(self.assets, uniquingKeysWith: { current, _ in current })
        } else {
            assets = self.assets
        }

        return Set(assets.values.compactMap {
            guard case let .filling(.image(.url(url, _))) = $0 else {
                return nil
            }
            return url
        })
    }
}
