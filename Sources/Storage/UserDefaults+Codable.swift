//
//  UserDefaults+Codable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2024
//
//

import Foundation

extension UserDefaults {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Backend.inUTCDateFormatter)
        encoder.dataEncodingStrategy = .base64
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Backend.dateFormatter)
        decoder.dataDecodingStrategy = .base64
        return decoder
    }()

    func setJSON(_ value: some Encodable, forKey key: String) throws {
        try set(UserDefaults.encoder.encode(value), forKey: key)
    }

    func getJSON<T>(_ type: T.Type, forKey key: String) throws -> T? where T: Decodable {
        guard let data = data(forKey: key) else { return nil }
        return try UserDefaults.decoder.decode(type, from: data)
    }
}
