//
//  VC.Image.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension VC {
    struct Image: Sendable, Hashable {
        let asset: AssetReference
        let aspect: AspectRatio
        let tint: AssetReference?
    }
}
