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
