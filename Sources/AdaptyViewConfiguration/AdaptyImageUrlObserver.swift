//
//  AdaptyImageUrlObserver.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.04.2024
//

import Foundation

package protocol AdaptyImageUrlObserver: Sendable {
    func extractedImageUrls(_: Set<URL>)
}

extension Adapty {
    private actor Holder {
        private(set) var imageUrlObserver: AdaptyImageUrlObserver?

        func set(imageUrlObserver observer: AdaptyImageUrlObserver) {
            imageUrlObserver = observer
        }
    }

    private static let holder = Holder()

    package nonisolated static func setImageUrlObserver(_ observer: AdaptyImageUrlObserver) {
        Task {
            await holder.set(imageUrlObserver: observer)
        }
    }

    static func sendImageUrlsToObserver(_ config: AdaptyViewSource) {
        Task {
            guard let observer = await holder.imageUrlObserver else { return }
            let urls = config.extractImageUrls(config.responseLocale)
            guard !urls.isEmpty else { return }
            observer.extractedImageUrls(urls)
        }
    }

    private static func sendImageUrlsToObserver(_ config: AdaptyPaywall.ViewConfiguration) {
        guard case let .value(value) = config else { return }
        sendImageUrlsToObserver(value)
    }

    static func sendImageUrlsToObserver(_ paywall: AdaptyPaywall) {
        guard let config = paywall.viewConfiguration else { return }
        sendImageUrlsToObserver(config)
    }
}
