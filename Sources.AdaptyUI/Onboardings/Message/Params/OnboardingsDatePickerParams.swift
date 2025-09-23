//
//  OnboardingsDatePickerParams.swift
//
//
//  Created by Aleksei Valiano on 09.08.2024
//
//

import Foundation

public struct OnboardingsDatePickerParams: Sendable, Hashable {
    public let day: Int?
    public let month: Int?
    public let year: Int?

    init(_ body: BodyDecoder.Value) throws {
        let body = try body.asDictionary()
        self.day = try body["day"].asOptionalInt()
        self.month = try body["month"].asOptionalInt()
        self.year = try body["year"].asOptionalInt()
    }
}

extension OnboardingsDatePickerParams: CustomDebugStringConvertible {
    public var debugDescription: String {
        "{day: \(day?.description ?? "nil"), month: \(month?.description ?? "nil"), year: \(year?.description ?? "nil")}"
    }
}
