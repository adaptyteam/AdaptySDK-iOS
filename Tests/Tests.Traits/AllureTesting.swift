//
//  AllureTesting.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 17.08.2026.
//

import Testing

public struct AllureTrait: TestTrait, SuiteTrait {
    let marks: [String]
    public let isRecursive: Bool

    public var comments: [Comment] {
        marks.map(Comment.init(rawValue:))
    }

    init(_ mark: String, isRecursive: Bool = false) {
        marks = [mark]
        self.isRecursive = isRecursive
    }

    init(_ marks: [String], isRecursive: Bool = false) {
        self.marks = marks
        self.isRecursive = isRecursive
    }

    public enum Risk: String, Sendable {
        case critical
        case high
        case normal
        case low
    }

    public enum Layer: String, Sendable {
        case unit
        case integration
        case ui
        case performance
        case regression
    }
}

public struct AllureIDTrait: TestTrait {
    let mark: String

    public var comments: [Comment] {
        [Comment(rawValue: mark)]
    }

    init(_ mark: String) {
        self.mark = mark
    }
}

public extension TestTrait where Self == AllureIDTrait {
    static func allureId(_ id: Int) -> Self {
        .init("#label.ALLURE_ID:\(id)")
    }

    static func allureId(_ id: String) -> Self {
        .init("#label.ALLURE_ID:\(id)")
    }
}

public extension Trait where Self == AllureTrait {
    static func flaky() -> Self {
        .init("#flag:flaky", isRecursive: true)
    }

    static func known() -> Self {
        .init("#flag:known", isRecursive: true)
    }

    static func muted() -> Self {
        .init("#flag:muted", isRecursive: true)
    }

    static var broken: Self {
        .init("#status:broken", isRecursive: true)
    }

    static func broken(_ reason: String? = nil) -> Self {
        if let reason, !reason.isEmpty {
            .init("#status:broken[\(reason)]", isRecursive: true)
        } else {
            .init("#status:broken", isRecursive: true)
        }
    }

    static func label(_ name: String, value: String) -> Self {
        .init("#label.\(name):\(value)", isRecursive: true)
    }

    static func component(_ value: String) -> Self {
        label("component", value: value)
    }

    static func epic(_ value: String) -> Self {
        label("epic", value: value)
    }

    static func feature(_ value: String) -> Self {
        label("feature", value: value)
    }

    static func story(_ value: String) -> Self {
        label("story", value: value)
    }

    static func risk(_ risk: AllureTrait.Risk) -> Self {
        label("risk", value: risk.rawValue)
    }

    static func owner(_ value: String) -> Self {
        label("owner", value: value)
    }

    static func lead(_ value: String) -> Self {
        label("lead", value: value)
    }

    static func layer(_ layer: AllureTrait.Layer) -> Self {
        label("layer", value: layer.rawValue)
    }

    static func link(name: String? = nil, url: String, type: String = "none") -> Self {
        let marker = [
            "#link:v1",
            encodeLinkMarkerField(type),
            encodeLinkMarkerField(name ?? ""),
            url,
        ].joined(separator: ":")
        return .init(marker, isRecursive: true)
    }

    static func issue(name: String? = nil, url: String) -> Self {
        link(name: name, url: url, type: "issue")
    }

    static func tms(name: String? = nil, url: String) -> Self {
        link(name: name, url: url, type: "tms")
    }
}

private func encodeLinkMarkerField(_ value: String) -> String {
    let hexadecimal = Array("0123456789ABCDEF".utf8)
    var result: [UInt8] = []
    result.reserveCapacity(value.utf8.count)

    for byte in value.utf8 {
        switch byte {
        case 65 ... 90, 97 ... 122, 48 ... 57, 45, 46, 95, 126:
            result.append(byte)
        default:
            result.append(37)
            result.append(hexadecimal[Int(byte >> 4)])
            result.append(hexadecimal[Int(byte & 0x0F)])
        }
    }

    return String(decoding: result, as: UTF8.self)
}

