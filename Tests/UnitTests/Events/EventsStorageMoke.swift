//
//  EventsStorage.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 18.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK
import Foundation

final class EventsStorageMoke: AdaptySDK.EventsStorage , AdaptySDK.EventsBackendConfigurationStorage {
    var data: [Data]?
    var config: EventsBackendConfiguration?

    var profileId: String
    var externalAnalyticsDisabled: Bool

    func setEvents(_ value: [Data]) { data = value }
    func getEvents() -> [Data]? { data }
    func clearEvents() { data = nil }

    func setEventsConfiguration(_ value: EventsBackendConfiguration) { config = value }
    func getEventsConfiguration() -> EventsBackendConfiguration? { config }

    init(profileId: String, externalAnalyticsDisabled: Bool) {
        self.profileId = profileId
        self.externalAnalyticsDisabled = externalAnalyticsDisabled
    }

    convenience init(externalAnalyticsDisabled: Bool) {
        self.init(profileId: Adapty.Configuration.existingProfileId, externalAnalyticsDisabled: externalAnalyticsDisabled)
    }


}
