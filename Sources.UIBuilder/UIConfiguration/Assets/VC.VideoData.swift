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
        /// Video height in pixels (number of pixels along the vertical axis). `0` if unknown.
        let verticalResolution: Int
        /// Video width in pixels (number of pixels along the horizontal axis). `0` if unknown.
        let horizontalResolution: Int
    }
}

extension VC.VideoData {
    /// Aspect ratio as `width / height`. `nil` when either resolution is unknown.
    var ratio: Double? {
        guard horizontalResolution > 0, verticalResolution > 0 else { return nil }
        return Double(horizontalResolution) / Double(verticalResolution)
    }
}
