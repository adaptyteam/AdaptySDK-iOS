//
//  OnboardingsSelectParams.swift
//
//
//  Created by Aleksei Valiano on 09.08.2024
//
//

import Foundation

public struct OnboardingsSelectParams: Sendable, Hashable {
    public let id: String
    public let value: String
    public let label: String

    init(_ body: BodyDecoder.Value) throws {
        let body = try body.asDictionary()
        self.id = try body["id"].asString()
        self.value = try body["value"].asString()
        self.label = try body["label"].asString()
    }
}

extension OnboardingsSelectParams: CustomDebugStringConvertible {
    public var debugDescription: String {
        "{id: \(id), value: \(value), label: \(label)}"
    }
}
