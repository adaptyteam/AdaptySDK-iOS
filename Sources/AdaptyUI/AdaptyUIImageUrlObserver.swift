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

    static func extractedImageUrls(_ urls: Set<URL>) {
        guard let observer = self.imageUrlObserver, !urls.isEmpty else { return }
        (dispatchQueue ?? .main).async {
            observer.extractedImageUrls(urls)
        }
    }
}
