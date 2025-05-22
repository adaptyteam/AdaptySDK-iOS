//
//  Storage+Codable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2024
//

import Foundation

extension Storage {
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

    @inlinable
    static func encode(_ value: some Encodable) throws -> Data {
        try encoder.encode(value)
    }

    @inlinable
    static func decode<T>(_ type: T.Type, from data: Data) throws -> T? where T: Decodable {
        try decoder.decode(type, from: data)
    }
}

extension UserDefaults {
    func setJSON(_ value: some Encodable, forKey key: String) throws {
        try set(Storage.encode(value), forKey: key)
    }

    func getJSON<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try Storage.decode(type, from: data)
    }
}
