//
//  VC.VideoData.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension VC {
    struct VideoData: Sendable {
        let customId: String?
        let url: URL
        let image: ImageData
        /// Video width in pixels. If the value is unknown, `0` is stored.
        let verticalResolution: Int
        /// Video height in pixels. If the value is unknown, `0` is stored.
        let horizontalResolution: Int
    }
}

extension VC.VideoData {
    var ratio: Double? {
        guard horizontalResolution > 0, verticalResolution > 0 else { return nil }
        return Double(verticalResolution) / Double(horizontalResolution)
    }
}
