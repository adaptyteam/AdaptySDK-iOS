//
//  VC.ImageData.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package extension VC {
    enum ImageData: CustomAsset, Sendable, Hashable {
        case raster(customId: String?, Data)
        case url(customId: String?, URL, previewRaster: Data?)
    }
}

extension VC.ImageData {
    package var customId: String? {
        switch self {
        case let .raster(customId, _),
             let .url(customId, _, _):
            customId
        }
    }

    var url: URL? {
        switch self {
        case let .url(_, url, _): url
        default: nil
        }
    }
}
