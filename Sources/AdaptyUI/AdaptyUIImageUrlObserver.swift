//
//  AdaptyUIImageUrlObserver.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 03.04.2024
//
//

import Foundation

package protocol AdaptyUIImageUrlObserver: Sendable {
    func extractedImageUrls(_: Set<URL>)
}

extension AdaptyUI {
    private actor Holder {
        private(set) var imageUrlObserver: AdaptyUIImageUrlObserver?

        func set(imageUrlObserver observer: AdaptyUIImageUrlObserver) {
            imageUrlObserver = observer
        }
    }

    private static let holder = Holder()

    package nonisolated static func setImageUrlObserver(_ observer: AdaptyUIImageUrlObserver) {
        Task {
            await holder.set(imageUrlObserver: observer)
        }
    }

    static func sendImageUrlsToObserver(_ config: AdaptyUI.ViewConfiguration) {
        Task {
            guard let observer = await holder.imageUrlObserver else { return }
            let urls = config.extractImageUrls(config.responseLocale)
            guard !urls.isEmpty else { return }
            observer.extractedImageUrls(urls)
        }
    }

    private static func sendImageUrlsToObserver(_ config: AdaptyPaywall.ViewConfiguration) {
        guard case let .data(value) = config else { return }
        sendImageUrlsToObserver(value)
    }

    static func sendImageUrlsToObserver(_ paywall: AdaptyPaywall) {
        guard let config = paywall.viewConfiguration else { return }
        sendImageUrlsToObserver(config)
    }
}
