//
//  EventsBackendConfigurationStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 31.03.2023
//

import Foundation

extension UserDefaults: EventsBackendConfigurationStorage {
    fileprivate enum Constants {
        static let eventsBackendConfigurationKey = "AdaptySDK_Events_Configuration"
    }

    func setEventsConfiguration(_ value: EventsBackendConfiguration) {
        do {
            let data = try Backend.encoder.encode(value)
            set(data, forKey: Constants.eventsBackendConfigurationKey)
            Log.debug("UserDefaults: Save Events Backend Configuration success.")
        } catch {
            Log.error("UserDefaults: saving Events Backend Configuration  fail. \(error.localizedDescription)")
        }
    }

    func getEventsConfiguration() -> EventsBackendConfiguration? {
        guard let data = data(forKey: Constants.eventsBackendConfigurationKey) else { return nil }
        do {
            return try Backend.decoder.decode(EventsBackendConfiguration.self, from: data)
        } catch {
            Log.warn(error.localizedDescription)
            return nil
        }
    }
}
