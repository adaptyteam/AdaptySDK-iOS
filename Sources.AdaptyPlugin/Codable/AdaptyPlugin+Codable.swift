//
//  AdaptyPlugin+Codable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

public extension AdaptyPlugin {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Backend.inUTCDateFormatter)
        encoder.dataEncodingStrategy = .base64
        encoder.enableEncodingViewConfiguration()
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Backend.dateFormatter)
        decoder.dataDecodingStrategy = .base64
        return decoder
    }()
}
