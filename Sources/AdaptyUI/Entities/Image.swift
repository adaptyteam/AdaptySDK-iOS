//
//  Image.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    public struct Image {
        static let defaultAspect = AspectRatio.fit
        public let asset: ImageData
        public let aspect: AspectRatio
        public let tint: Filling?
    }
}
