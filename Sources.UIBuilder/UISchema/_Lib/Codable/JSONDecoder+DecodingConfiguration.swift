//
//  JSONDecoder+DecodingConfiguration.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 05.12.2025.
//

import Foundation

extension JSONDecoder {
    func decode<T: DecodableWithConfiguration>(
        _ type: T.Type,
        from data: Data,
        with configuration: T.DecodingConfiguration
    ) throws -> T where T.DecodingConfiguration: Sendable {
        let decoder = JSONDecoder()
        decoder.userInfo[configurationCodingUserInfoKey] = configuration

        let wrapper = try decoder.decode(
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
