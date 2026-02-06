//
//  VC.CornerRadiusTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 06.02.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUIConfigurationTests {
    @Suite("VC.CornerRadius Tests")
    struct VCCornerRadiusTests {
        typealias Value = VC.CornerRadius
    }
}

private extension AdaptyUIConfigurationTests.VCCornerRadiusTests {
    // MARK: - test create

    @Test("Test base init", arguments: [
        (topLeading: 0, topTrailing: 0, bottomTrailing: 0, bottomLeading: 0),
        (topLeading: 1, topTrailing: 1, bottomTrailing: 1, bottomLeading: 1),
        (topLeading: 1, topTrailing: 2, bottomTrailing: 3, bottomLeading: 4),
    ])
    func create(topLeading: Double, topTrailing: Double, bottomTrailing: Double, bottomLeading: Double) throws {
        let value = Value(
            topLeading: topLeading,
            topTrailing: topTrailing,
            bottomTrailing: bottomTrailing,
            bottomLeading: bottomLeading
        )

        #expect(value.topLeading == topLeading)
        #expect(value.topTrailing == topTrailing)
        #expect(value.bottomTrailing == bottomTrailing)
        #expect(value.bottomLeading == bottomLeading)
    }

    @Test("Test same value", arguments: [0, -1, 5, 5.5])
    func createSameRadius(radius: Double) throws {
        let value = Value(same: radius)
        #expect(value.topLeading == radius)
        #expect(value.topTrailing == radius)
        #expect(value.bottomTrailing == radius)
        #expect(value.bottomLeading == radius)
    }

    // MARK: - zero

    @Test("Test zero value")
    func zero() throws {
        let value = Value.zero
        #expect(value.topLeading == 0)
        #expect(value.topTrailing == 0)
        #expect(value.bottomTrailing == 0)
        #expect(value.bottomLeading == 0)
    }

    // MARK: - isZero

    @Test("Test isZero property", arguments: [
        Value.zero,
        Value(same: 0),
        Value(topLeading: 0, topTrailing: 0, bottomTrailing: 0, bottomLeading: 0),
    ])
    func isZero(value: Value) throws {
        #expect(value.isZero)
    }

    @Test("Negative test isZero  property", arguments: [
        Value(same: 1),
        Value(topLeading: 1, topTrailing: 0, bottomTrailing: 0, bottomLeading: 0),
        Value(topLeading: 0, topTrailing: 1, bottomTrailing: 0, bottomLeading: 0),
        Value(topLeading: 0, topTrailing: 0, bottomTrailing: 1, bottomLeading: 0),
        Value(topLeading: 0, topTrailing: 0, bottomTrailing: 0, bottomLeading: 1),
    ])
    func isNotZero(value: Value) throws {
        #expect(!value.isZero)
    }

    // MARK: - isSameRadius

    @Test("Test isSameRadius property", arguments: [
        Value.zero,
        Value(same: 15),
        Value(topLeading: 10, topTrailing: 10, bottomTrailing: 10, bottomLeading: 10),
    ])
    func isSameRadius(value: Value) throws {
        #expect(value.isSameRadius)
    }

    @Test("Negative test isSameRadius property", arguments: [
        Value(topLeading: 0, topTrailing: 10, bottomTrailing: 10, bottomLeading: 10),
        Value(topLeading: 10, topTrailing: 0, bottomTrailing: 10, bottomLeading: 10),
        Value(topLeading: 10, topTrailing: 10, bottomTrailing: 0, bottomLeading: 10),
        Value(topLeading: 10, topTrailing: 10, bottomTrailing: 10, bottomLeading: 0),
    ])
    func isNotSameRadius(value: Value) throws {
        #expect(!value.isSameRadius)
    }
}
