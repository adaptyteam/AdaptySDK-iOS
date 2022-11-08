//
//  Requests_Profile.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 10.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest
import AppTrackingTransparency


final class Requests_Profile: XCTestCase {
    let goodBackendId = "profile"
    let badBackendId = "profile_bad"

    var profileParameters: AdaptyProfileParameters!
    var installationMeta: Environment.Meta!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let customAttributes: AdaptyProfile.CustomAttributes =
            [
                "custom_nil": .nil,
                "custom_string": .string("str_value"),
                "custom_float": .float(1984.84),
            ]

        profileParameters = AdaptyProfileParameters.Builder()
            .with(firstName: "John")
            .with(lastName: "Appleseed")
            .with(gender: .male)
            .with(birthday: Date(timeIntervalSince1970: 907452000))
            .with(email: "johnappleseed@apple.com")
            .with(phoneNumber: "+1234567890")
            .with(facebookUserId: "facebook_123123123")
            .with(facebookAnonymousId: "facebook_an_123123123")
            .with(amplitudeUserId: "amplitude_123123")
            .with(amplitudeDeviceId: "amplitude_device_12321312")
            .with(mixpanelUserId: "mixpanel_123123")
            .with(appmetricaProfileId: "appmetrica_12123")
            .with(appmetricaDeviceId: "appmetrica_device_12123")
            .with(appTrackingTransparencyStatus: ATTrackingManager.AuthorizationStatus.notDetermined)
            .with(customAttributes: customAttributes)
            .with(analyticsDisabled: false)
            .build()

        installationMeta = Environment.Meta(includedAnalyticIds: true)
    }

    override func tearDownWithError() throws {
        profileParameters = nil
        installationMeta = nil

        try super.tearDownWithError()
    }

    func test_Create_Update_Fetch() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()

        let createProfileExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let createProfileRequest = CreateProfileRequest(profileId: profileId, customerUserId: nil, parameters: nil, environmentMeta: installationMeta)
        session.perform(createProfileRequest) { (result: CreateProfileRequest.Result) in
            switch result {
            case let .success(response):
                let profile = response.body.value

                XCTAssertEqual(profile.profileId, profileId)
                XCTAssertEqual(response.statusCode, 201)
            case .failure:
                XCTAssertFalse(true)
            }

            createProfileExpectation.fulfill()
        }

        wait(for: [createProfileExpectation], timeout: TestsConstants.timeoutInterval)

        let updateProfileExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let updateProfileRequest = UpdateProfileRequest(profileId: profileId,
                                                        parameters: profileParameters,
                                                        environmentMeta: nil,
                                                        responseHash: nil)

        session.perform(updateProfileRequest) { (result: UpdateProfileRequest.Result) in
            switch result {
            case let .success(response):
                let profile = response.body.value

                XCTAssertEqual(profile?.profileId, profileId)
                XCTAssertEqual(response.statusCode, 200)
            case .failure:
                XCTAssertFalse(true)
            }

            updateProfileExpectation.fulfill()
        }

        wait(for: [updateProfileExpectation], timeout: TestsConstants.timeoutInterval)

        let fetchProfileExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let fetchProfileRequest = FetchProfileRequest(profileId: profileId, responseHash: nil)
        session.perform(fetchProfileRequest) { (result: FetchProfileRequest.Result) in
            switch result {
            case let .success(response):
                let profile = response.body.value

                XCTAssertEqual(profile?.profileId, profileId)
                XCTAssertEqual(response.statusCode, 200)
            case .failure:
                XCTAssertFalse(true)
            }

            fetchProfileExpectation.fulfill()
        }

        wait(for: [fetchProfileExpectation], timeout: TestsConstants.timeoutInterval)
    }

    func test_Fetch_NoProfile() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = FetchProfileRequest(profileId: profileId, responseHash: nil)
        session.perform(request) { (result: FetchProfileRequest.Result) in
            expectation.fulfill()

            switch result {
            case let .success(response):
                let profile = response.body.value

                XCTAssertEqual(profile?.profileId, profileId)
                XCTAssertEqual(response.statusCode, 201)
            case .failure:
                XCTAssertFalse(true)
            }
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_Update_NoProfile() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = UpdateProfileRequest(profileId: profileId,
                                           parameters: profileParameters,
                                           environmentMeta: installationMeta,
                                           responseHash: nil)

        session.perform(request) { (result: UpdateProfileRequest.Result) in
            expectation.fulfill()

            HTTPAssertResponseFailed(result, 404)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_Create_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: badBackendId, secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = CreateProfileRequest(profileId: profileId, customerUserId: nil, parameters: nil, environmentMeta: Environment.Meta(includedAnalyticIds: true))
        session.perform(request) { (result: CreateProfileRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseFailed(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_Fetch_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: badBackendId, secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = FetchProfileRequest(profileId: profileId, responseHash: nil)
        session.perform(request) { (result: FetchProfileRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseFailed(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_Update_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: badBackendId, secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = UpdateProfileRequest(profileId: profileId,
                                           parameters: profileParameters,
                                           environmentMeta: installationMeta,
                                           responseHash: nil)

        session.perform(request) { (result: UpdateProfileRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseFailed(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_CustomAttributes_LongStringException() {
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId: String = TestsConstants.existingProfileId

        let updateProfileRequest = UpdateProfileRequest(profileId: profileId,
                                                        parameters: AdaptyProfileParameters(customAttributes: [
                                                            "long_string": .string("1234567890_1234567890_1234567890"),
                                                        ]),
                                                        environmentMeta: nil,
                                                        responseHash: nil)

        session.perform(updateProfileRequest) { (result: UpdateProfileRequest.Result) in
            HTTPAssertErrorBackendCodeEqual(result, 400)
            expectation.fulfill()
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_CustomAttributes_EmptyStringException() {
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId: String = TestsConstants.existingProfileId

        let updateProfileRequest = UpdateProfileRequest(profileId: profileId,
                                                        parameters: AdaptyProfileParameters(customAttributes: [
                                                            "long_string": .string(""),
                                                        ]),
                                                        environmentMeta: nil,
                                                        responseHash: nil)

        session.perform(updateProfileRequest) { (result: UpdateProfileRequest.Result) in
            // Maybe here should be an error
            HTTPAssertResponseSuccess(result, 200)
//            HTTPAssertErrorBackendCodeEqual(result, 400)
            expectation.fulfill()
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_CustomAttributes_EmptyKeyException() {
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId: String = TestsConstants.existingProfileId

        let updateProfileRequest = UpdateProfileRequest(profileId: profileId,
                                                        parameters: AdaptyProfileParameters(customAttributes: [
                                                            "": .string("value"),
                                                        ]),
                                                        environmentMeta: nil,
                                                        responseHash: nil)

        session.perform(updateProfileRequest) { (result: UpdateProfileRequest.Result) in
            HTTPAssertErrorBackendCodeEqual(result, 400)
            expectation.fulfill()
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
