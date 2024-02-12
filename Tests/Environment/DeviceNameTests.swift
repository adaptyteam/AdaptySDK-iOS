//
//  DeviceNameTests.swift
//
//
//  Created by Aleksei Valiano on 09.02.2024
//
//
@testable import Adapty
import XCTest

final class DeviceNameTests: XCTestCase {
    func testDeviceName() {
        let deviceName = Environment.Device.name

        XCTAssertFalse(deviceName.isEmpty)
        XCTAssertFalse(deviceName.contains { $0 == "\u{0}" })
    }
}
