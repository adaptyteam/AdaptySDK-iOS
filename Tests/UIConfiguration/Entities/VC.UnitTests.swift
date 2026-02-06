//
//  VC.UnitTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 06.02.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUIConfigurationTests {
    @Suite("VC.Unit Tests")
    struct VCUnitTests {
        typealias Value = VC.Unit
    }
}

private extension AdaptyUIConfigurationTests.VCUnitTests {
    // MARK: - isZero

    @Test("Test isZero property", arguments: [
        Value.point(0),
        Value.screen(0)
    ])
    func isZero(value: Value) throws {
        #expect(value.isZero)
    }

    @Test("Negative test isZero  property", arguments: [
        Value.point(10),
        Value.screen(10),
        Value.safeArea(.end),
        Value.safeArea(.start)
    ])
    func isNotZero(value: Value) throws {
        #expect(!value.isZero)
    }
}
