//
//  AdaptyUIImageUrlObserver.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 03.04.2024
//
//

import Foundation

public protocol AdaptyUIImageUrlObserver {
    func extractedImageUrls(_: Set<URL>)
}

extension AdaptyUI {
    static var dispatchQueue: DispatchQueue?
    static var imageUrlObserver: AdaptyUIImageUrlObserver?
    static func setImageUrlObserver(_ observer: AdaptyUIImageUrlObserver, dispatchQueue: DispatchQueue) {
        imageUrlObserver = observer
        self.dispatchQueue = dispatchQueue
    }
}

extension AdaptyResult<AdaptyUI.ViewConfiguration> {
    func sendImageUrlsToObserver(forLocale local: AdaptyLocale) {
        if let observer = AdaptyUI.imageUrlObserver,
           case let .success(value) = self {
            (AdaptyUI.dispatchQueue ?? .main).async {
                let urls = value.extractImageUrls(local)
                guard !urls.isEmpty else { return }
                observer.extractedImageUrls(urls)
            }
        }
    }
}
