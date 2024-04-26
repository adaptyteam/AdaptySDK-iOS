//
//  Image.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Image {
        static let `default` = Image(
            asset: .none,
            aspect: AspectRatio.fit,
            tint: nil
        )

        package let asset: ImageData
        package let aspect: AspectRatio
        package let tint: Filling?
    }
}
