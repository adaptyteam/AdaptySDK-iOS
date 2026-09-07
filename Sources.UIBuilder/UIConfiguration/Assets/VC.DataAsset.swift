//
//  VC.DataAsset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 31.08.2026.
//

import Foundation

extension VC {
    struct DataAsset: Sendable {
        let url: URL?
        let value: Data?
        let customId: String?
        let format: String
    }
}
