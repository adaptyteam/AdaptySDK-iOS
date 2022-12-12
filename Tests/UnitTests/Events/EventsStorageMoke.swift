//
//  EventsStorage.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 18.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK
import Foundation

final class EventsStorageMoke: AdaptySDK.EventsStorage {
    var data: [Data]?

    var profileId: String
    var externalAnalyticsDisabled: Bool

    func setEvents(_ value: [Data]) { data = value }
    func getEvents() -> [Data]? { data }
    func clearEvents() { data = nil }

    init(profileId: String, externalAnalyticsDisabled: Bool) {
        self.profileId = profileId
        self.externalAnalyticsDisabled = externalAnalyticsDisabled
    }

    convenience init(externalAnalyticsDisabled: Bool) {
        self.init(profileId: Adapty.Configuration.existingProfileId, externalAnalyticsDisabled: externalAnalyticsDisabled)
    }
}
