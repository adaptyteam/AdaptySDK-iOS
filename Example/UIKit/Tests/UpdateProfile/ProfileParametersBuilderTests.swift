//
//  ProfileParametersBuilderTests.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 19.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class ProfileParametersBuilderTests: XCTestCase {
    func test_ParametersBuilder_Success() {
        var builder = ProfileParameters.Builder()

        do {
            builder = try builder.with(customAttribute: "123", forKey: "123")
        } catch {
            XCTFail()
        }
    }

    func test_ParametersBuilder_EmptyValue() {
        let expectation = expectation(description: "Expectation for 1 sec.")
        var builder = ProfileParameters.Builder()

        do {
            builder = try builder.with(customAttribute: "", forKey: "123")
        } catch {
            expectation.fulfill()

            guard let adaptyError = error as? AdaptyError else {
                XCTFail()
                return
            }

            XCTAssertEqual(adaptyError.adaptyErrorCode, AdaptyError.ErrorCode.wrongParam)
        }

        waitForExpectations(timeout: 1.0)
    }

    func test_ParametersBuilder_EmptyKey() {
        let expectation = expectation(description: "Expectation for 1 sec.")
        var builder = ProfileParameters.Builder()

        do {
            builder = try builder.with(customAttribute: "123", forKey: "")
        } catch {
            expectation.fulfill()

            guard let adaptyError = error as? AdaptyError else {
                XCTFail()
                return
            }

            XCTAssertEqual(adaptyError.adaptyErrorCode, AdaptyError.ErrorCode.wrongParam)
        }

        waitForExpectations(timeout: 1.0)
    }

    func test_ParametersBuilder_LongKey() {
        let expectation = expectation(description: "Expectation for 1 sec.")
        var builder = ProfileParameters.Builder()

        do {
            builder = try builder.with(customAttribute: "123", forKey: "1234567890_1234567890_1234567890")
        } catch {
            expectation.fulfill()

            guard let adaptyError = error as? AdaptyError else {
                XCTFail()
                return
            }

            XCTAssertEqual(adaptyError.adaptyErrorCode, AdaptyError.ErrorCode.wrongParam)
        }

        waitForExpectations(timeout: 1.0)
    }

    func test_ParametersBuilder_LongValue() {
        let expectation = expectation(description: "Expectation for 1 sec.")
        var builder = ProfileParameters.Builder()

        do {
            builder = try builder.with(customAttribute: "1234567890_1234567890_1234567890", forKey: "123")
        } catch {
            expectation.fulfill()

            guard let adaptyError = error as? AdaptyError else {
                XCTFail()
                return
            }

            XCTAssertEqual(adaptyError.adaptyErrorCode, AdaptyError.ErrorCode.wrongParam)
        }

        waitForExpectations(timeout: 1.0)
    }

    // ._-
    func test_ParametersBuilder_WrongKeySymbols() {
        let expectation = expectation(description: "Expectation for 1 sec.")
        var builder = ProfileParameters.Builder()

        do {
            builder = try builder.with(customAttribute: "123", forKey: "some$strange^&&*string")
        } catch {
            expectation.fulfill()

            guard let adaptyError = error as? AdaptyError else {
                XCTFail()
                return
            }

            XCTAssertEqual(adaptyError.adaptyErrorCode, AdaptyError.ErrorCode.wrongParam)
        }

        waitForExpectations(timeout: 1.0)
    }

    func test_ParametersBuilder_KeysOverflow() {
        let expectation = expectation(description: "Expectation for 1 sec.")

        var overflowedBuilder = ProfileParameters.Builder()
        do {
            try (0 ..< 11).forEach { i in
                overflowedBuilder = try overflowedBuilder.with(customAttribute: "value_\(i)", forKey: "key_\(i)")
            }
        } catch {
            expectation.fulfill()

            guard let adaptyError = error as? AdaptyError else {
                XCTFail()
                return
            }

            XCTAssertEqual(adaptyError.adaptyErrorCode, AdaptyError.ErrorCode.wrongParam)
        }

        waitForExpectations(timeout: 1.0)
    }

    func test_ParametersBuilder_SendData() throws {
        var builder = ProfileParameters.Builder()
            .with(firstName: "John")
            .with(lastName: "Appleseed")
            .with(gender: .male)
            .with(birthday: Date(timeIntervalSince1970: 1000000))
            .with(email: "johnappleseed@apple.com")
            .with(phoneNumber: "+1234567890")
            .with(facebookUserId: "facebook_123123123")
            .with(facebookAnonymousId: "facebook_an_123123123")
            .with(amplitudeUserId: "amplitude_123123")
            .with(amplitudeDeviceId: "amplitude_device_12321312")
            .with(mixpanelUserId: "mixpanel_123123")
            .with(appmetricaProfileId: "appmetrica_12123")
            .with(appmetricaDeviceId: "appmetrica_device_12123")

        builder = builder.with(appTrackingTransparencyStatus: .authorized)
        builder = try builder.with(customAttribute: "test", forKey: "test")
        builder = builder.with(analyticsDisabled: false)

        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let (_, session) = Tester.createBackendAndSession(id: "parameters_builder")
        let profileId: String = TestsConstants.existingProfileId

        let updateProfileRequest = UpdateProfileRequest(profileId: profileId,
                                                        parameters: builder.build(),
                                                        environmentMeta: nil,
                                                        responseHash: nil)

        session.perform(updateProfileRequest) { (result: UpdateProfileRequest.Result) in
            HTTPAssertResponseSuccess(result, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
