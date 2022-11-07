//
//  EventsManagerTests.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 19.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

// final class ProfileStorageForTest: ProfileStorage {
//    var profileId: String
//    var profile: VH<Profile>?
//
//    var externalAnalyticsDisabled: Bool
//    var syncedBundleReceipt: Bool
//
//    func getProfile() -> VH<Profile>? { profile }
//    func setProfile(_ value: VH<Profile>) { profile = value }
//
//
//    init(profileId: String, externalAnalyticsDisabled: Bool, syncedBundleReceipt: Bool) {
//        self.profileId = profileId
//        self.externalAnalyticsDisabled = externalAnalyticsDisabled
//        self.syncedBundleReceipt = syncedBundleReceipt
//    }
//
//
//    func resetProfileId(_ id: String?) {
//        guard let id = id else {
//            profileId = UUID().uuidString.lowercased()
//            return
//        }
//        profileId = id
//    }
//
//    func clearProfile() {
//        syncedBundleReceipt = false
//        externalAnalyticsDisabled = false
//    }
// }

final class EventsManagerTests: XCTestCase {
    let profileId: String = TestsConstants.existingProfileId
    var backend: Backend!
    var manager: EventsManager!

    override func setUpWithError() throws {
        (backend, _) = Tester.createBackendAndSession(id: "kinesis")
        manager = EventsManager(storage: EventsStorageForTest(profileId: profileId, externalAnalyticsDisabled: false), backend: backend)
    }

    func test_AnalyticsDisabled_Error() {
        let expectationAppOpened = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let manager = EventsManager(storage: EventsStorageForTest(profileId: profileId, externalAnalyticsDisabled: true), backend: backend)

        manager.trackEvent(Event(type: .appOpened, profileId: profileId)) { error in
            expectationAppOpened.fulfill()

            DispatchQueue.main.async {
                guard let error = error else {
                    XCTFail()
                    return
                }

                switch error {
                case .analyticsDisabled:
                    break
                default:
                    XCTFail()
                }
            }
        }

        wait(for: [expectationAppOpened], timeout: TestsConstants.timeoutInterval)

        let expectationPaywallShowed = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        manager.trackEvent(Event(type: .paywallShowed(.init(variationId: "test")), profileId: profileId)) { error in
            DispatchQueue.main.async {
                XCTAssertNotNil(error)
                expectationPaywallShowed.fulfill()
            }
        }

        wait(for: [expectationPaywallShowed], timeout: TestsConstants.timeoutInterval)
    }

    func test_ChangeProfileId() {
        let expectation1 = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let expectation2 = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let storage = EventsStorageForTest(profileId: profileId, externalAnalyticsDisabled: false)
        let manager = EventsManager(storage: storage, backend: backend)
        manager.trackEvent(Event(type: .appOpened, profileId: profileId)) { error in
            DispatchQueue.main.async {
                XCTAssertNil(error)
                expectation1.fulfill()
            }
        }

        let newProfileId = UUID().uuidString
        storage.profileId = newProfileId

        manager.trackEvent(Event(type: .appOpened, profileId: profileId)) { error in
            DispatchQueue.main.async {
                XCTAssertNil(error)
                expectation2.fulfill()
            }
        }

        wait(for: [expectation1, expectation2], timeout: TestsConstants.timeoutInterval)
    }

    func test_Event_AppOpened() {
        manager.trackEvent(Event(type: .appOpened, profileId: profileId)) { error in
            DispatchQueue.main.async {
                XCTAssertNil(error)
            }
        }
    }

    func test_Event_OnboargingShown() {
        manager.trackEvent(Event(type: .onboardingScreenShowed(.init(name: "test_onboarding", screenName: "test_screen", screenOrder: 1)), profileId: profileId)) { error in
            DispatchQueue.main.async {
                XCTAssertNil(error)
            }
        }
    }

    func test_Event_PaywallShown() {
        manager.trackEvent(Event(type: .paywallShowed(.init(variationId: "test_variation_id")), profileId: profileId)) { error in
            DispatchQueue.main.async {
                XCTAssertNil(error)
            }
        }
    }
}
