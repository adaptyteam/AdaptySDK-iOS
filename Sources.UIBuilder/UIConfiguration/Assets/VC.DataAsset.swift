//
//  VC.DataAsset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 31.08.2026.
//

import Foundation

extension VC {
    struct DataAsset: Sendable {
        enum Source: Sendable {
            case value(Data)
            case url(URL)
        }

        let customId: String?
        let format: String
        let source: Source
    }
}
