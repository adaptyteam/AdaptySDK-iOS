//
//  VC.PointTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 06.02.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUIConfigurationTests {
    @Suite("VC.Point Tests")
    struct VCPointTests {
        typealias Value = VC.Point
    }
}

private extension AdaptyUIConfigurationTests.VCPointTests {
    // MARK: - test create

    @Test("Test base init", arguments: [
        (x: 0, y: 0),
        (x: 1, y: 2),
    ])
    func create(x: Double, y: Double) throws {
        let value = Value(
            x: x,
            y: y
        )

        #expect(value.x == x)
        #expect(value.y == y)
    }
    
    // MARK: - isZero

    @Test("Test isZero property")
    func isZero() throws {
        let value = Value(x: 0, y: 0)
        #expect(value.isZero)
    }

    @Test("Negative test isZero  property", arguments: [
        Value(x: 10, y: 10),
        Value(x: 0, y: 10),
        Value(x: 10, y: 0)
    ])
    func isNotZero(value: Value) throws {
        #expect(!value.isZero)
    }
}
