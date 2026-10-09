//
//  Schema.MapConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension Schema {
    typealias MapConverter = VC.MapConverter
}

extension Schema.MapConverter: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Schema.Converter.CodingKeys.self)
        try self.init(values: container.decode([Schema.Value].self, forKey: .converterParameters))
    }
}
