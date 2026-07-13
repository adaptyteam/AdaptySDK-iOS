//
//  JSONDecoder+DecodingConfiguration.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 05.12.2025.
//

import Foundation

public extension JSONDecoder {
    /// Workaround: `JSONDecoder.decode(_:from:configuration:)` is only available on macOS 14+ / iOS 17+.
    /// This method provides the same functionality for earlier OS versions using `CodingUserInfoKey`.
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


