//
//  Asset.Image.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public enum Image {
        case raster(Data)
//        case vector(Data)
        case url(URL, previewRaster: Data?)
    }
}
