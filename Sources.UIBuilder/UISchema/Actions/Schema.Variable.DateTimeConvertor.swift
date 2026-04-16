//
//  Schema.Variable.DateTimeConvertor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension Schema.Variable.DateTimeConvertor: Decodable {
    private enum CodingKeys: String, CodingKey {
        case format
        case date
        case time
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Schema.Variable.CodingKeys.self)

        if let value = try? container.decode(String.self, forKeys: .converterParameters) {
            self = .format(value)
            return
        }

        let params = try container.nestedContainer(keyedBy: CodingKeys.self, forKeys: .converterParameters)

        if let value = try params.decodeIfPresent(String.self, forKeys: .format) {
            self = .format(value)
            return
        }

        self = try .styles(
            date: params.decodeIfPresent(String.self, forKeys: .date).flatMap(DateFormatter.Style.init) ?? .none,
            time: params.decodeIfPresent(String.self, forKeys: .time).flatMap(DateFormatter.Style.init) ?? .none
        )
    }
}

