//
//  AdaptyProfileParameters.AppTrackingTransparencyStatus.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.12.2022
//

import Foundation

extension AdaptyProfileParameters {
    public enum AppTrackingTransparencyStatus: Equatable, Sendable {
        case unknown
        case notDetermined
        case restricted
        case denied
        case authorized
    }
}

extension AdaptyProfileParameters.AppTrackingTransparencyStatus {
    enum CodingStringValues: String {
        case unknown
        case notDetermined = "not_determined"
        case restricted
        case denied
        case authorized
    }

    enum CodingIntValues: Int {
        case unknown = -1
        case notDetermined = 0
        case restricted = 1
        case denied = 2
        case authorized = 3
    }

    var intRawValue: Int {
        let value: CodingIntValues =
            switch self {
            case .notDetermined: .notDetermined
            case .restricted: .restricted
            case .denied: .denied
            case .authorized: .authorized
            case .unknown: .unknown
            }
        return value.rawValue
    }

    var stringRawValue: String {
        let value: CodingStringValues =
            switch self {
            case .notDetermined: .notDetermined
            case .restricted: .restricted
            case .denied: .denied
            case .authorized: .authorized
            case .unknown: .unknown
            }
        return value.rawValue
    }

    init(from value: String) {
        let value = CodingStringValues(rawValue: value)
        switch value {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        case .authorized: self = .authorized
        default: self = .unknown
        }
    }

    init(from value: Int) {
        let value = CodingIntValues(rawValue: value)
        switch value {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        case .authorized: self = .authorized
        default: self = .unknown
        }
    }
}

extension AdaptyProfileParameters.AppTrackingTransparencyStatus: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self.init(from: value)
        } else {
            try self.init(from: container.decode(String.self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(intRawValue)
    }
}
