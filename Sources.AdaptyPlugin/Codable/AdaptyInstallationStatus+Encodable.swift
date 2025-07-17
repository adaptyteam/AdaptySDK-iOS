//
//  AdaptyInstallationStatus+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 26.06.2025.
//

import Adapty
import Foundation

extension AdaptyInstallationStatus: Encodable {
    private enum CodingKeys: CodingKey {
        case status
        case details
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .notAvailable:
            try container.encode("not_available", forKey: .status)
        case .notDetermined:
            try container.encode("not_determined", forKey: .status)
        case .determined(let details):
            try container.encode("determined", forKey: .status)
            try container.encode(details, forKey: .details)
        }
    }

    @inlinable
    public var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}
