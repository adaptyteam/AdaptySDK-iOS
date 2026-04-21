//
//  VC.DateTimeConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.02.2026.
//

import Foundation

extension VC {
    enum DateTimeConverter: Converter {
        case format(String)
        case styles(date: DateFormatter.Style, time: DateFormatter.Style)
    }
}

extension VC.DateTimeConverter {
    private nonisolated(unsafe) static let cache = NSCache<NSString, DateFormatter>()

    var formatter: DateFormatter {
        let key: NSString =
            switch self {
            case let .format(f): "f:\(f)" as NSString
            case let .styles(d, t): "s:\(d.rawValue)-\(t.rawValue)" as NSString
            }

        if let cached = Self.cache.object(forKey: key) { return cached }
        let formatter = DateFormatter()
        switch self {
        case let .format(f): formatter.dateFormat = f
        case let .styles(d, t):
            formatter.dateStyle = d
            formatter.timeStyle = t
        }
        Self.cache.setObject(formatter, forKey: key)
        return formatter
    }

    @inlinable
    func toString(unixtimestamp: Double) -> String {
        formatter.string(from: Date(timeIntervalSince1970: unixtimestamp / 1000.0))
    }

    func toString(_ value: Any) -> String? {
        switch value {
        case let value as Date:
            formatter.string(from: value)
        case is Bool:
            nil
        case let value as NSNumber:
            toString(unixtimestamp: value.doubleValue)
        default:
            nil
        }
    }
}

extension DateFormatter.Style {
    init?(fromString: String) {
        switch fromString {
        case "none":
            self = .none
        case "full":
            self = .full
        case "long":
            self = .long
        case "medium":
            self = .medium
        case "short":
            self = .short
        default:
            return nil
        }
    }

    var stringValue: String {
        switch self {
        case .none:
            "none"
        case .full:
            "full"
        case .long:
            "long"
        case .medium:
            "medium"
        case .short:
            "short"
        @unknown default:
            "none"
        }
    }
}

