//
//  VC.Image.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    struct Image: Sendable, Hashable {
        package let asset: Mode<ImageData>
        package let aspect: AspectRatio
        package let tint: Mode<Filling>?
    }
}

#if DEBUG
package extension VC.Image {
    static func create(
        asset: VC.Mode<VC.ImageData>,
        aspect: VC.AspectRatio = .default,
        tint: VC.Mode<VC.Filling>? = nil
    ) -> Self {
        .init(
            asset: asset,
            aspect: aspect,
            tint: tint
        )
    }
}
#endif
