//
//  VC.Image.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    struct Image: Sendable, Hashable {
        package let asset: AssetReference
        package let aspect: AspectRatio
        package let tint: AssetReference?
    }
}
