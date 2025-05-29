//
//  OnboardingsDatePickerParams+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 28.05.2025.
//

import AdaptyUI
import Foundation

extension OnboardingsDatePickerParams: Encodable {
    enum CodingKeys: String, CodingKey {
        case day
        case month
        case year
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(day, forKey: .day)
        try container.encodeIfPresent(month, forKey: .month)
        try container.encodeIfPresent(year, forKey: .year)
    }
}
