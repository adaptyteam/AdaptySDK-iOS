//
//  AdaptyUIImageUrlObserver.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 03.04.2024
//

import Foundation

package protocol AdaptyUIImageUrlObserver: Sendable {
    func extractedImageUrls(_: Set<URL>)
}

extension AdaptyUIBuilder {
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

    package nonisolated static func sendImageUrlsToObserver(_ schema: AdaptyUISchema, forLocalId localeId: LocaleId) {
        Task {
            guard let observer = await holder.imageUrlObserver else { return }
            let urls = schema.extractImageUrls(forLocalId: localeId)
            guard urls.isNotEmpty else { return }
            observer.extractedImageUrls(urls)
        }
    }
}
