//
//  AdaptyUIImageUrlObserver.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 03.04.2024
//
//

import Foundation

package protocol AdaptyUIImageUrlObserver {
    func extractedImageUrls(_: Set<URL>)
}

extension AdaptyUI {
    static var dispatchQueue: DispatchQueue?
    static var imageUrlObserver: AdaptyUIImageUrlObserver?
    package static func setImageUrlObserver(_ observer: AdaptyUIImageUrlObserver, dispatchQueue: DispatchQueue) {
        imageUrlObserver = observer
        self.dispatchQueue = dispatchQueue
    }
}

extension AdaptyUI.ViewConfiguration {
    func sendImageUrlsToObserver() {
        guard let observer = AdaptyUI.imageUrlObserver else { return }
        let urls = self.extractImageUrls(responseLocale)
        guard !urls.isEmpty else { return }

        (AdaptyUI.dispatchQueue ?? .main).async {
            observer.extractedImageUrls(urls)
        }
    }
}

extension AdaptyPaywall {
    func sendImageUrlsToObserver() {
        guard let viewConfiguration,
              case let .data(value) = viewConfiguration
        else { return }
        value.sendImageUrlsToObserver()
    }
}
