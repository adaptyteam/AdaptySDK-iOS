//
//  Schema.Variable.MapConvertor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension Schema.Variable.MapConvertor: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Schema.Variable.CodingKeys.self)
        try self.init(values: container.decode([Schema.AnyValue].self, forKey: .converterParameters))
    }
}

