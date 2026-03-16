//
//  VC.VideoData.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension VC {
    struct VideoData: Sendable, Hashable {
        let customId: String?
        let url: URL
        let image: ImageData
    }
}
