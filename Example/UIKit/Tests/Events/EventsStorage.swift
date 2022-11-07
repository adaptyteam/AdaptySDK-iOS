//
//  EventsStorage.swift
//  Adapty_Tests
//
//  Created by Alexey Valiano on 21.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import Foundation

class EventsStorageForTest: EventsStorage {
    var value: [Data]?

    var profileId: String
    var externalAnalyticsDisabled: Bool

    func setEvents(_ value: [Data]) { self.value = value }
    func getEvents() -> [Data]? { value }
    func clearEvents() { value = nil }

    init(profileId: String, externalAnalyticsDisabled: Bool) {
        self.profileId = profileId
        self.externalAnalyticsDisabled = externalAnalyticsDisabled
    }
}
