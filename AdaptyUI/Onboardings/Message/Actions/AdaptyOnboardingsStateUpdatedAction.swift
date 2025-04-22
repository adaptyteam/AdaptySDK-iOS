//
//  AdaptyOnboardingsStateUpdatedAction.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import Foundation

public struct AdaptyOnboardingsStateUpdatedAction: Sendable, Hashable {
    public let elementId: String
    public let meta: AdaptyOnboardingsMetaParams
    public let params: OnboardingsStateUpdatedParams

    init(_ body: BodyDecoder.Dictionary) throws {
        self.elementId = try body["element_id"].asString()
        self.meta = try AdaptyOnboardingsMetaParams(body["meta"])

        enum ValueType: String {
            case select
            case multiSelect = "multi_select"
            case input
            case datePicker = "date_picker"
        }

        guard let valueType = try ValueType(rawValue: body["element_type"].asString()) else {
            throw BodyDecoderError.wrongValue
        }

        self.params =
            switch valueType {
            case .datePicker:
                try .datePicker(.init(body["value"]))
            case .input:
                try .input(.init(body["value"]))
            case .select:
                try .select(.init(body["value"]))
            case .multiSelect:
                try .multiSelect(
                    body["value"].asArray().map { try OnboardingsSelectParams($0) }
                )
            }
    }
}

extension AdaptyOnboardingsStateUpdatedAction: CustomDebugStringConvertible {
    public var debugDescription: String {
        "{elementId: \(elementId), params: \(params.debugDescription), meta: \(meta.debugDescription)}"
    }
}
