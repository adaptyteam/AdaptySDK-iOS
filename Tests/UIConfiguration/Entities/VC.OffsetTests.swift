//
//  VC.OffsetTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 06.02.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUIConfigurationTests {
    @Suite("VC.Offset Tests")
    struct VCOffsetTests {
        typealias Value = VC.Offset
    }
}

private extension AdaptyUIConfigurationTests.VCOffsetTests {
    // MARK: - test create

    static let createArguments: [(x: VC.Unit, y: VC.Unit)] = [
        (x: .point(0), y: .point(0)),
        (x: .screen(0), y: .screen(0)),
        (x: .point(1), y: .point(2)),
        (x: .screen(0), y: .point(10)),
        (x: .safeArea(.end), y: .point(0))
    ]

    @Test("Test base init", arguments: createArguments)
    func create(x: VC.Unit, y: VC.Unit) throws {
        let value = Value(
            x: x,
            y: y
        )

        #expect(value.x == x)
        #expect(value.y == y)
    }

    // MARK: - isZero

    @Test("Test isZero property", arguments: [
        Value(x: .point(0), y: .point(0)),
        Value(x: .screen(0), y: .screen(0))
    ])
    func isZero(value: Value) throws {
        #expect(value.isZero)
    }

    @Test("Negative test isZero  property", arguments: [
        Value(x: .point(0), y: .safeArea(.end)),
        Value(x: .screen(0), y: .point(10)),
        Value(x: .point(10), y: .screen(0.5)),
        Value(x: .point(0), y: .screen(0.2))
    ])
    func isNotZero(value: Value) throws {
        #expect(!value.isZero)
    }
}
