//
//  Image.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    public struct Image {
        static let `default` = Image(
            asset: .none,
            aspect: AspectRatio.fit,
            tint: nil
        )

        public let asset: ImageData
        public let aspect: AspectRatio
        public let tint: Filling?
    }
}
