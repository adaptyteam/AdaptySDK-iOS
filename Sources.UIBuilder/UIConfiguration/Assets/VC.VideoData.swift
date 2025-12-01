//
//  VC.VideoData.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

package extension VC {
    struct VideoData: CustomAsset, Sendable, Hashable {
        package let customId: String?
        package let url: URL
        package let image: ImageData
    }
}

#if DEBUG
package extension VC.VideoData {
    static func create(
        customId: String? = nil,
        url: URL,
        image: VC.ImageData
    ) -> Self {
        .init(
            customId: customId,
            url: url,
            image: image
        )
    }
}
#endif
