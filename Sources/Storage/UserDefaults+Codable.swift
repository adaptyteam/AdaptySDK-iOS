//
//  UserDefaults+Codable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2024
//
//

import Foundation

extension UserDefaults {
    fileprivate static let isStorageCodableUserInfoKey = CodingUserInfoKey(rawValue: "adapty_storage")!

    static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Backend.inUTCDateFormatter)
        encoder.dataEncodingStrategy = .base64
        encoder.setIsStorage()
        return encoder
    }()

    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Backend.dateFormatter)
        decoder.dataDecodingStrategy = .base64
        decoder.setIsStorage()
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

private extension CodingUserInfoСontainer {
    func setIsStorage() {
        userInfo[UserDefaults.isStorageCodableUserInfoKey] = true
    }
}

extension [CodingUserInfoKey: Any] {
    var isStorage: Bool {
        [UserDefaults.isStorageCodableUserInfoKey] as? Bool ?? false
    }
}
