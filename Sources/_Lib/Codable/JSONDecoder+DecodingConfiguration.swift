//
//  JSONDecoder+DecodingConfiguration.swift
//  Adapty
//
//  Created by Aleksei Valiano on 03.04.2026.
//

import Foundation

extension JSONDecoder {
    
    func decode<T: DecodableWithConfiguration>(
        _ type: T.Type,
        from data: Data,
        with configuration: T.DecodingConfiguration
    ) throws -> T where T.DecodingConfiguration: Sendable {
        if #available(macOS 14, iOS 17, tvOS 17, watchOS 10, *) {
            return try decode(type, from: data, configuration: configuration)
        }

        userInfo[configurationCodingUserInfoKey] = configuration

        let wrapper = try decode(
            ConfigurationDecodingWrapper<T>.self,
            from: data
        )

        return wrapper.wrapped
    }
}

private let configurationCodingUserInfoKey = CodingUserInfoKey(rawValue: "configuration")!

private struct ConfigurationDecodingWrapper<Wrapped: DecodableWithConfiguration>: Decodable {
    var wrapped: Wrapped

    init(from decoder: Decoder) throws {
        let configuration = decoder.userInfo[configurationCodingUserInfoKey]

        wrapped = try Wrapped(
            from: decoder,
            configuration: configuration as! Wrapped.DecodingConfiguration
        )
    }
}

