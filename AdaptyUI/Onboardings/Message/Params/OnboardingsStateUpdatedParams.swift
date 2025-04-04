//
//  OnboardingsStateUpdatedParams.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import Foundation

public enum OnboardingsStateUpdatedParams: Sendable, Hashable {
    case select(OnboardingsSelectParams)
    case multiSelect([OnboardingsSelectParams])
    case input(OnboardingsInputParams)
    case datePicker(OnboardingsDatePickerParams)
}

extension OnboardingsStateUpdatedParams: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .select(params):
            params.debugDescription
        case let .multiSelect(array):
            "[\(array.map { $0.debugDescription }.joined(separator: ", "))]"
        case let .input(params):
            params.debugDescription
        case let .datePicker(params):
            params.debugDescription
        }
    }
}
