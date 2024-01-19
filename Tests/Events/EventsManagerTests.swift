//
//  EventsManagerTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 19.11.2022
//

@testable import Adapty
import XCTest

final class EventsManagerTests: XCTestCase {
    var backend: Backend!
    var profileStorage: ProfileIdentifierStorageMoke!
    var storage: EventsStorageMoke!
    var sysLogStorage: EventsStorageMoke!
    var manager: EventsManager!

    override func setUp() {
        backend = Backend.createForTests()
        storage = EventsStorageMoke()
        sysLogStorage = EventsStorageMoke()
        profileStorage = ProfileIdentifierStorageMoke()
        manager = EventsManager(profileStorage: profileStorage, eventStorages: [storage, sysLogStorage], backend: backend)
    }

    var allEventTypes: [EventType] = [
        .appOpened,
        .onboardingScreenShowed(.init(name: "test_onboarding", screenName: "test_screen", screenOrder: 1)),
        .paywallShowed(.init(paywallVariationId: "test_variation_id", viewConfigurationId: nil)),
    ]

    func XCTAssertTrackEventType(_ eventType: EventType, assert: ((EventsError?) -> Void)? = nil) {
        XCTAssertTrackEvent(Event(type: eventType, profileId: profileStorage.profileId), assert: assert)
    }

    func XCTAssertTrackEvent(_ event: Event, assert: ((EventsError?) -> Void)? = nil) {
        let expectation = expectation(description: "wait trackEvent")

        manager.trackEvent(event) { error in
            expectation.fulfill()
            if let assert = assert {
                assert(error)
            } else {
                XCTAssertNil(error)
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testTrackEvents() {
        allEventTypes.forEach {
            XCTAssertTrackEventType($0)
        }
    }

    func testChangeProfileId() {
        XCTAssertGreaterThan(allEventTypes.count, 1)

        allEventTypes.forEach {
            XCTAssertTrackEventType($0)
            profileStorage.profileId = UUID().uuidString
        }
    }
}
