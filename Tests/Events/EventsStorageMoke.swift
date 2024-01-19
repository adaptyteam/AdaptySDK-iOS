//
//  EventsStorage.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 18.11.2022
//

@testable import Adapty
import Foundation

final class EventsStorageMoke: EventsStorage {

    var data: [Data]?
    var config: EventsBackendConfiguration?
    var counter = 0

    func setEventCounter(_ value: Int) { counter = value}
    func getEventCounter() -> Int { counter }
    func setEvents(_ value: [Data]) { data = value }
    func getEvents() -> [Data]? { data }
    func clearEvents() { data = nil }
}
