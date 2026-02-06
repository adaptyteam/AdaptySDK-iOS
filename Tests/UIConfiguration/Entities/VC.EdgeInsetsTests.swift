//
//  VC.EdgeInsetsTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 06.02.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUIConfigurationTests {
    @Suite("VC.EdgeInsets Tests")
    struct VCEdgeInsetsTests {
        typealias Value = VC.EdgeInsets
    }
}

private extension AdaptyUIConfigurationTests.VCEdgeInsetsTests {
    // MARK: - test create

    static let createArguments: [(leading: VC.Unit, top: VC.Unit, trailing: VC.Unit, bottom: VC.Unit)] = [
        (leading: .point(0), top: .point(0), trailing: .point(0), bottom: .point(0)),
        (leading: .screen(0), top: .screen(0), trailing: .screen(0), bottom: .screen(0)),
        (leading: .point(1), top: .point(2), trailing: .point(3), bottom: .point(4)),
        (leading: .screen(0), top: .point(10), trailing: .safeArea(.start), bottom: .point(0)),
        (leading: .safeArea(.end), top: .point(0), trailing: .screen(0), bottom: .point(0)),
    ]

    @Test("Test base init", arguments: createArguments)
    func create(leading: VC.Unit, top: VC.Unit, trailing: VC.Unit, bottom: VC.Unit) throws {
        let value = Value(
            leading: leading,
            top: top,
            trailing: trailing,
            bottom: bottom
        )

        #expect(value.leading == leading)
        #expect(value.top == top)
        #expect(value.trailing == trailing)
        #expect(value.bottom == bottom)
    }

    static let createSameArguments: [VC.Unit] = [
        .point(0),
        .point(10),
        .screen(0),
        .screen(0.5),
        .safeArea(.end),
        .safeArea(.start),
    ]

    @Test("Test same value", arguments: createSameArguments)
    func createSame(v: VC.Unit) throws {
        let value = Value(same: v)
        #expect(value.leading == v)
        #expect(value.top == v)
        #expect(value.trailing == v)
        #expect(value.bottom == v)
    }

    // MARK: - isZero

    @Test("Test isZero property", arguments: [
        Value(same: .point(0)),
        Value(same: .screen(0)),
        Value(leading: .point(0), top: .point(0), trailing: .point(0), bottom: .point(0)),
        Value(leading: .screen(0), top: .screen(0), trailing: .screen(0), bottom: .screen(0)),
    ])
    func isZero(value: Value) throws {
        #expect(value.isZero)
    }

    @Test("Negative test isZero  property", arguments: [
        Value(same: .point(1)),
        Value(same: .screen(0.5)),
        Value(leading: .point(0), top: .safeArea(.end), trailing: .point(0), bottom: .point(0)),
        Value(leading: .screen(0), top: .screen(0), trailing: .safeArea(.start), bottom: .screen(0)),
        Value(leading: .point(1), top: .point(0), trailing: .point(0), bottom: .point(0)),
        Value(leading: .screen(0), top: .screen(0), trailing: .screen(0), bottom: .screen(1)),
    ])
    func isNotZero(value: Value) throws {
        #expect(!value.isZero)
    }

    // MARK: - isSame

    @Test("Test isSame property", arguments: [
        Value(same: .point(0)),
        Value(same: .point(1)),
        Value(same: .screen(0.5)),
        Value(same: .screen(0)),
        Value(same: .safeArea(.start)),
        Value(leading: .point(0), top: .point(0), trailing: .point(0), bottom: .point(0)),
        Value(leading: .screen(0), top: .screen(0), trailing: .screen(0), bottom: .screen(0)),
        Value(leading: .point(2), top: .point(2), trailing: .point(2), bottom: .point(2)),
        Value(leading: .screen(0.2), top: .screen(0.2), trailing: .screen(0.2), bottom: .screen(0.2)),
        Value(leading: .safeArea(.start), top: .safeArea(.start), trailing: .safeArea(.start), bottom: .safeArea(.start)),
    ])
    func isSameRadius(value: Value) throws {
        #expect(value.isSame)
    }

    @Test("Negative test isSameRadius property", arguments: [
        Value(leading: .point(0), top: .safeArea(.start), trailing: .point(0), bottom: .point(0)),
        Value(leading: .screen(0), top: .screen(0), trailing: .safeArea(.end), bottom: .screen(0)),
        Value(leading: .point(2), top: .point(2), trailing: .point(2), bottom: .screen(0.2)),
        Value(leading: .screen(0), top: .screen(0.2), trailing: .screen(0.2), bottom: .screen(0.2)),
        Value(leading: .safeArea(.end), top: .safeArea(.start), trailing: .safeArea(.start), bottom: .safeArea(.start)),
    ])
    func isNotSameRadius(value: Value) throws {
        #expect(!value.isSame)
    }
}
