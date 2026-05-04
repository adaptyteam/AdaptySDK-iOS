//
//  Schema.DateTimeConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension Schema {
    typealias DateTimeConverter = VC.DateTimeConverter
}

extension Schema.DateTimeConverter: Decodable {
    private enum CodingKeys: String, CodingKey {
        case format
        case date = "date_style"
        case time = "time_style"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(String.self, forKeys: .format) {
            self = .format(value)
            return
        }

        self = try .styles(
            date: container.decodeIfPresent(String.self, forKeys: .date).flatMap(DateFormatter.Style.init) ?? .none,
            time: container.decodeIfPresent(String.self, forKeys: .time).flatMap(DateFormatter.Style.init) ?? .none
        )
    }
}

