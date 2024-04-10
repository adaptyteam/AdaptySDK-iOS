//
//  File.swift
//
//
//  Created by Aleksei Valiano on 08.04.2024
//
//

import Foundation

extension Event {
    fileprivate static let isEventsCodableUserInfoKey = CodingUserInfoKey(rawValue: "adapty_events")!

    static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Backend.inUTCDateFormatter)
        encoder.dataEncodingStrategy = .base64
        encoder.setIsEvents()
        return encoder
    }()

    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Backend.inUTCDateFormatter)
        decoder.dataDecodingStrategy = .base64
        decoder.setIsEvents()
        return decoder
    }()
}

private extension CodingUserInfoСontainer {
    func setIsEvents() {
        userInfo[Event.isEventsCodableUserInfoKey] = true
    }
}

extension [CodingUserInfoKey: Any] {
    var isEvents: Bool {
        [Event.isEventsCodableUserInfoKey] as? Bool ?? false
    }
}
